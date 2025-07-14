module ShellyplugExporter
  # Represents the exporter configuration, supporting multiple plugs.
  class Config
    property exporter_port : Int32
    property plugs : Array(PlugConfig)

    # Loads configuration from a YAML file or environment variables.
    def self.load(yaml_path : String? = nil) : self
      if yaml_path && File.exists?(yaml_path)
        load_from_yaml(yaml_path)
      else
        load_from_env
      end
    end

    private def self.load_from_yaml(yaml_path : String) : self
      data = YAML.parse(File.read(yaml_path))
      exporter_port = data["exporter_port"]?.try(&.as_i) || ENV.fetch("EXPORTER_PORT", "5000").to_i

      plugs = data["plugs"]?.try(&.as_a).try &.map do |plug|
        PlugConfig.new(
          plug["name"].as_s,
          plug["host"].as_s,
          plug["port"].as_i,
          plug["auth_username"]?.try(&.as_s?),
          plug["auth_password"]?.try(&.as_s?)
        )
      end || [] of PlugConfig

      new(exporter_port, plugs)
    end

    private def self.load_from_env : self
      exporter_port = ENV.fetch("EXPORTER_PORT", "5000").to_i
      plugs = [PlugConfig.new(
        nil, # Empty name for single plug
        ENV.fetch("SHELLYPLUG_HOST", "192.168.33.1"),
        ENV.fetch("SHELLYPLUG_PORT", "80").to_i,
        ENV["SHELLYPLUG_AUTH_USERNAME"]?,
        ENV["SHELLYPLUG_AUTH_PASSWORD"]?
      )]

      new(exporter_port, plugs)
    end

    def initialize(@exporter_port : Int32, @plugs : Array(PlugConfig)); end
  end
end
