module ShellyplugExporter
  # Represents a Shelly plug device and provides methods to query data from it.
  class Plug
    property name : String?
    property config : PlugConfig
    property client : PlugClient

    def initialize(@config : PlugConfig)
      @client = PlugClient.new(@config)
      @name = @config.name.presence || fetch_name
    end

    def query_data : Hash(Symbol, Float64 | Int64)
      response = @client.fetch_status
      data = parse_response(response)
      query_data_by_generation(data)
    end

    private def fetch_name : String?
      response = @client.fetch_settings
      if response.status_code == 200
        @config.last_request_succeeded = true
        config_json = JSON.parse(response.body)
        extract_name_by_generation(config_json)
      else
        log_and_set_failure("Failed to fetch plug name for #{@config.host}, using default.")
        nil
      end
    rescue ex
      log_and_set_failure("Exception fetching plug name for #{@config.host}: #{ex.message}")
      nil
    end

    private def parse_response(response : HTTP::Client::Response) : JSON::Any
      if response.status_code == 200
        @config.last_request_succeeded = true
        return JSON.parse(response.body)
      end

      log_invalid_response(response.status_code)
      @config.last_request_succeeded = false
      JSON.parse("{}")
    end

    private def query_data_by_generation(data : JSON::Any) : Hash(Symbol, Float64 | Int64)
      case @config.generation
      when PlugGeneration::Gen1
        Gen::PlugGen1.query_data(data)
      when PlugGeneration::Gen2
        Gen::PlugGen2.query_data(data)
      else
        {} of Symbol => (Float64 | Int64)
      end
    end

    private def extract_name_by_generation(config_json : JSON::Any) : String?
      case @config.generation
      when PlugGeneration::Gen1
        Gen::PlugGen1.extract_name(config_json)
      when PlugGeneration::Gen2
        Gen::PlugGen2.extract_name(config_json)
      end
    end

    private def log_and_set_failure(message : String)
      Log.error { message }
      @config.last_request_succeeded = false
    end

    private def log_invalid_response(status_code : Int32)
      if status_code == 408
        Log.error { "Timeout error for #{@config.host}, check plug status." }
      else
        Log.error { "Invalid response from #{@config.host}, check plug status." }
      end
    end
  end
end
