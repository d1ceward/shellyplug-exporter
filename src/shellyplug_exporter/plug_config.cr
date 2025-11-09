module ShellyplugExporter
  # Enum for Shelly plug generation
  enum PlugGeneration
    Gen1
    Gen2
  end

  # Represents the configuration for a single Shelly plug device.
  class PlugConfig
    property name : String
    property host : String
    property port : Int32
    property generation : PlugGeneration
    property auth_username : String?
    property auth_password : String?
    property last_request_succeeded : Bool?

    def initialize(@name : String,
                   @host : String,
                   @port : Int32,
                   @generation : PlugGeneration = PlugGeneration::Gen1,
                   @auth_username : String? = nil,
                   @auth_password : String? = nil,
                   @last_request_succeeded : Bool? = nil)
    end
  end
end
