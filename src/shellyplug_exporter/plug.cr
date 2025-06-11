module ShellyplugExporter
  # Plug class represents a Shelly plug device and provides methods to query data from it.
  #
  # ```
  # config = ShellyplugExporter::Config.new
  # ShellyplugExporter::Plug.new(config)
  # ```
  class Plug
    property name : String? = nil

    @client : ShellyplugExporter::PlugClient

    def initialize(@config : Config) : Nil
      @client = ShellyplugExporter::PlugClient.new(@config)
      @name = fetch_name
    end

    def query_data : Hash(Symbol, Float64 | Int64)
      response = @client.fetch_status
      data = parse_response(response)

      meter = data["meters"]?.try(&.[0])

      {
        :power => meter.try(&.["power"]?).try(&.as_f?) || 0_f64,
        :overpower => meter.try(&.["overpower"]?).try(&.as_f?) || 0_f64,
        :total => meter.try(&.["total"]?).try(&.as_i64?) || 0_i64,
        :temperature => data["temperature"]?.try(&.as_f?) || 0_f64,
        :uptime => data["uptime"]?.try(&.as_i64?) || 0_i64
      }
    end

    private def fetch_name : String?
      response = @client.fetch_settings

      if response.status_code == 200
        settings = JSON.parse(response.body)

        settings["name"]?.try(&.as_s?)
      else
        Log.error { "Failed to fetch plug name, using default." }

        nil
      end
    rescue
      nil
    end

    private def parse_response(response : HTTP::Client::Response) : JSON::Any
      if response.status_code == 200
        @config.last_request_succeded = true

        return JSON.parse(response.body)
      end

      if response.status_code == 408
        Log.error { "Timeout error, please check your environment variable or plug status." }
      else
        Log.error { "Invalid response, please check your environment variable or plug status." }
      end

      @config.last_request_succeded = false
      JSON.parse("{}")
    end
  end
end
