module ShellyplugExporter
  # Represents a Shelly plug device and provides methods to query data from it.
  class Plug
    property name : String?
    property config : PlugConfig
    property client : PlugClient

    # Initialize with a PlugConfig
    def initialize(@config : PlugConfig)
      @client = PlugClient.new(@config)
      @name = @config.name.presence || fetch_name
    end

    # Queries the plug for metrics data.
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
        @config.last_request_succeeded = true
        settings = JSON.parse(response.body)

        settings["name"]?.try(&.as_s?)
      else
        Log.error { "Failed to fetch plug name for #{@config.host}, using default." }
        @config.last_request_succeeded = false

        nil
      end
    rescue ex
      Log.error { "Exception fetching plug name for #{@config.host}: #{ex.message}" }
      @config.last_request_succeeded = false

      nil
    end

    private def parse_response(response : HTTP::Client::Response) : JSON::Any
      if response.status_code == 200
        @config.last_request_succeeded = true
        return JSON.parse(response.body)
      end

      if response.status_code == 408
        Log.error { "Timeout error for #{@config.host}, check plug status." }
      else
        Log.error { "Invalid response from #{@config.host}, check plug status." }
      end

      @config.last_request_succeeded = false
      JSON.parse("{}")
    end
  end
end
