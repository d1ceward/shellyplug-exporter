module ShellyplugExporter
  class Plug
    API_ENDPOINT = "/meter/0"

    def initialize(@config : Config); end

    def query_data : Hash(Symbol, Float64 | Int64)
      response = execute_request
      data = parse_response(response)

      {
        :power => data["power"]?.try(&.as_f?) || 0_f64,
        :total => data["total"]?.try(&.as_i64?) || 0_i64
      }
    end

    private def execute_request : HTTP::Client::Response
      client = HTTP::Client.new(@config.shellyplug_host, 80)
      client.connect_timeout = 4

      if @config.shellyplug_auth_username && @config.shellyplug_auth_password
        client.basic_auth(@config.shellyplug_auth_username, @config.shellyplug_auth_password)
      end

      client.get(API_ENDPOINT)
    rescue IO::TimeoutError
      HTTP::Client::Response.new(408)
    end

    private def parse_response(response : HTTP::Client::Response)
      return JSON.parse(response.body) if response.status_code == 200

      if response == 408
        puts "Timeout error, please check your environment variable or plug status."
      else
        puts "Invalid response, please check your environment variable or plug status."
      end

      JSON.parse("{}")
    end
  end
end
