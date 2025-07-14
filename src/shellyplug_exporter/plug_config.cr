module ShellyplugExporter
  # Represents the configuration for a single Shelly plug device.
  class PlugConfig
    property name : String?
    property host : String?
    property port : Int32?
    property auth_username : String?
    property auth_password : String?
    property last_request_succeded : Bool?

    def initialize(@name : String,
                   @host : String,
                   @port : Int32,
                   @auth_username : String? = nil,
                   @auth_password : String? = nil,
                   @last_request_succeded : Bool? = nil)
    end
  end
end
