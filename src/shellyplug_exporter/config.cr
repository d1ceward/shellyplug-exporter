module ShellyplugExporter
  class Config
    property exporter_port : Int32
    property plug_host : String
    property plug_port : Int32
    property plug_auth_username : String?
    property plug_auth_password : String?

    def initialize
      @exporter_port = ENV.fetch("EXPORTER_PORT", "5000").to_i32
      @plug_host = ENV.fetch("SHELLYPLUG_HOST", "192.168.33.1")
      @plug_port = ENV.fetch("SHELLYPLUG_PORT", "80").to_i32
      @plug_auth_username = ENV["SHELLYPLUG_AUTH_USERNAME"]?
      @plug_auth_password = ENV["SHELLYPLUG_AUTH_PASSWORD"]?
    end
  end
end
