module ShellyplugExporter
  class Config
    getter exporter_server_port : Int32
    getter shellyplug_host : String
    getter shellyplug_auth_username : String?
    getter shellyplug_auth_password : String?

    def initialize(port : Int32?)
      @exporter_server_port = port || ENV.fetch("EXPORTER_SERVER_PORT", "80").to_i32
      @shellyplug_host = ENV.fetch("SHELLYPLUG_HOST", "192.168.33.1")
      @shellyplug_auth_username = ENV["SHELLYPLUG_AUTH_USERNAME"]?
      @shellyplug_auth_password = ENV["SHELLYPLUG_AUTH_PASSWORD"]?
    end
  end
end
