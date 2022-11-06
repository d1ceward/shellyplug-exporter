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
    # Port through which the web server of the exporter will be accessible.
    property exporter_port : Int32

    # Hostname or ip address of the plug.
    property plug_host : String

    # Port of the plug api.
    property plug_port : Int32

    # Username for authentication of the plug (can be configured in the plug).
    property plug_auth_username : String?

    # Password for authentication of the plug (can be configured in the plug).
    property plug_auth_password : String?

    # Boolean representing if last request of the plug was successful.
    property last_request_succeded : Bool? = nil

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
