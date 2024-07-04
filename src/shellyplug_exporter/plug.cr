module ShellyplugExporter
  # Plug class represents a Shelly plug device and provides methods to query data from it.
  #
  # ```
  # config = ShellyplugExporter::Config.new
  # ShellyplugExporter::Plug.new(config)
  # ```
  class Plug
    # API endpoint for querying plug status.
    API_ENDPOINT = "/status"

    # Initialize a new Plug instance.
    def initialize(@config : Config) : Nil; end

    # Query data from the plug device.
    def query_data : Hash(Symbol, Float64 | Int64)
      response = execute_request
      data = parse_response(response)

      # Data about power consumption.
      meter = data["meters"]?.try(&.[0])

      {
        :power => meter.try(&.["power"]?).try(&.as_f?) || 0_f64,
        :overpower => meter.try(&.["overpower"]?).try(&.as_f?) || 0_f64,
        :total => meter.try(&.["total"]?).try(&.as_i64?) || 0_i64,
        :temperature => data["temperature"]?.try(&.as_f?) || 0_f64,
        :uptime => data["uptime"]?.try(&.as_i64?) || 0_i64
      }
    end

    private def execute_request : HTTP::Client::Response
      client = HTTP::Client.new(@config.plug_host, @config.plug_port)
      client.connect_timeout = 4.seconds

      if @config.plug_auth_username && @config.plug_auth_password
        client.basic_auth(@config.plug_auth_username, @config.plug_auth_password)
      end

      client.get(API_ENDPOINT)
    rescue IO::TimeoutError | Socket::Addrinfo::Error | Socket::ConnectError
      HTTP::Client::Response.new(408)
    end

    private def parse_response(response : HTTP::Client::Response) : JSON::Any
      if response.status_code == 200
        @config.last_request_succeded = true

        return JSON.parse(response.body)
      end

      if response == 408
        Log.error { "Timeout error, please check your environment variable or plug status." }
      else
        Log.error { "Invalid response, please check your environment variable or plug status." }
      end

      @config.last_request_succeded = false

      JSON.parse("{}")
    end
  end
end
