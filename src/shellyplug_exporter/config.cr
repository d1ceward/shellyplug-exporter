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
      data = YAML.parse(File.read(yaml_path))
      unless data.raw
        STDERR.puts("YAML config file #{yaml_path} is empty or invalid.")
        exit(1)
      end

      exporter_port = data["exporter_port"]?.try(&.as_i) || env_exporter_port
      plugs_nodes = parse_plugs(data["plugs"]?.try(&.as_a))

      new(exporter_port, plugs_nodes)
    rescue ex : IO::Error | File::NotFoundError
      STDERR.puts("YAML config file #{yaml_path} not found: #{ex.message}")
      exit(1)
    rescue ex : YAML::ParseException
      STDERR.puts("Failed to parse YAML config file #{yaml_path}: #{ex.message}")
      exit(1)
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
      ENV.fetch("EXPORTER_PORT", "3000").to_i
    end

    private def self.parse_plugs(plugs_node) : Array(PlugConfig)
      return [] of PlugConfig unless plugs_node

      plugs_node.map do |plug|
        PlugConfig.new(
          plug["name"].as_s,
          plug["host"].as_s,
          plug["port"].as_i,
          plug["auth_username"]?.try(&.as_s?),
          plug["auth_password"]?.try(&.as_s?)
        )
      end
    end
  end
end
