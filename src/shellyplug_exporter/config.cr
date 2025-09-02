module ShellyplugExporter
  # Represents the exporter configuration, supporting multiple plugs.
  class Config
    property exporter_port : Int32
    property plugs : Array(PlugConfig)

    def initialize(@exporter_port : Int32, @plugs : Array(PlugConfig)); end

    # Loads configuration from a YAML file or environment variables.
    def self.load(yaml_path : String? = nil) : self
      yaml_path ? load_from_yaml(yaml_path) : load_from_env
    end

    private def self.load_from_yaml(yaml_path : String) : self
      raw_content = File.read(yaml_path)
      interpolated_content = interpolate_env(raw_content)
      data = YAML.parse(interpolated_content)

      abort_with_error("YAML config file #{yaml_path} is empty or invalid.") unless data.raw

      port_value = data["exporter_port"]?
      exporter_port = port_value.try(&.as_i?) ||
              port_value.try(&.as_s?).try(&.to_i?) ||
              env_exporter_port
      plugs_nodes = parse_plugs(data["plugs"]?.try(&.as_a?))
      new(exporter_port, plugs_nodes)
    rescue ex : IO::Error | File::NotFoundError
      abort_with_error("YAML config file #{yaml_path} not found: #{ex.message}")
    rescue ex : YAML::ParseException
      abort_with_error("Failed to parse YAML config file #{yaml_path}: #{ex.message}")
    end

    private def self.load_from_env : self
      new(
        env_exporter_port,
        [PlugConfig.new(
          "", # Use empty string for name
          ENV.fetch("SHELLYPLUG_HOST", "192.168.33.1"),
          ENV.fetch("SHELLYPLUG_PORT", "80").to_i,
          ENV["SHELLYPLUG_AUTH_USERNAME"]?,
          ENV["SHELLYPLUG_AUTH_PASSWORD"]?
        )]
      )
    end

    private def self.env_exporter_port : Int32
      ENV.fetch("EXPORTER_PORT", "5000").to_i
    end

    private def self.parse_plugs(plugs_node) : Array(PlugConfig)
      return [] of PlugConfig unless plugs_node

      plugs_node.map do |plug|
        name = plug["name"]?.try(&.as_s?)
        host = plug["host"]?.try(&.as_s?)
        port = plug["port"]?.try(&.as_i?)

        unless name && host && port
          abort_with_error("Plug config missing required fields: name, host, or port.")
        end

        PlugConfig.new(
          name,
          host,
          port,
          plug["auth_username"]?.try(&.as_s?),
          plug["auth_password"]?.try(&.as_s?)
        )
      end
    end

    # Interpolates environment variables in the YAML content
    private def self.interpolate_env(content : String) : String
      content.gsub(/\$\{([^}]+)\}/) do |match|
        interpolate_env_var($1, match)
      end
    end

    # Helper to handle environment variable interpolation logic
    private def self.interpolate_env_var(expression : String, fallback : String) : String
      matches = /^([A-Za-z_][A-Za-z0-9_]*)(:-|\-|:\?|[?])?(.*)?$/.match(expression)
      return fallback unless matches

      variable = matches[1]
      operator = matches[2]? || ""
      remainder = matches[3]? || ""
      value = ENV[variable]?

      handle_env_operator(operator, value, variable, remainder)
    end

    private def self.handle_env_operator(
      operator : String,
      value : String?,
      variable : String,
      remainder : String
    ) : String
      return value || remainder if operator == ":-"
      return value ? value : remainder if operator == "-"
      return require_env_var(value, variable, remainder) if operator == ":?"
      return require_env_var_nonempty(value, variable, remainder) if operator == "?"

      value || ""
    end

    private def self.require_env_var(value : String?, variable : String, remainder : String) : String
      return value if value
      abort_with_error("Environment variable #{variable} is required: #{remainder}")
    end

    private def self.require_env_var_nonempty(value : String?, variable : String, remainder : String) : String
      return value if value && !value.empty?
      abort_with_error("Environment variable #{variable} is required: #{remainder}")
    end

    # Helper to print error and exit
    private def self.abort_with_error(message : String) : NoReturn
      STDERR.puts(message)
      exit(1)
    end
  end
end
