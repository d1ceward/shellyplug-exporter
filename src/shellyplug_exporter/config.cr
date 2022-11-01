module ShellyplugExporter
  # A configuration entry for the program.
  #
  # Config can be loaded from environment variables and adjusted.
  #
  # ```
  # config = ShellyplugExporter::Config.new
  # config.exporter_port = my_exporter_port
  # ```
  class Config
    # Export server port.
    property exporter_port : Int32

    # Shelly Plug S hostname or IP in the network of exporter.
    property plug_host : String

    # Shelly Plug S port
    property plug_port : Int32

    # Shelly Plug S authentication username (can be configured in the plug).
    property plug_auth_username : String?

    # Shelly Plug S authentication password (can be configured in the plug).
    property plug_auth_password : String?

    # Last plug status (if request succeded or not).
    property last_plug_status : Bool? = nil

    # Creates a new instance of `ShellyplugExporter::Config` based on environment variables.
    def initialize
      @exporter_port = ENV.fetch("EXPORTER_PORT", "5000").to_i32
      @plug_host = ENV.fetch("SHELLYPLUG_HOST", "192.168.33.1")
      @plug_port = ENV.fetch("SHELLYPLUG_PORT", "80").to_i32
      @plug_auth_username = ENV["SHELLYPLUG_AUTH_USERNAME"]?
      @plug_auth_password = ENV["SHELLYPLUG_AUTH_PASSWORD"]?
    end
  end
end
