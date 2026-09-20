module ShellyplugExporter
  # Represents a Shelly plug device and provides methods to query data from it.
  class Plug
    property name : String?
    property config : PlugConfig
    property client : PlugClient

    def initialize(@config : PlugConfig) : Nil
      @client = PlugClient.new(@config)
      @name_resolved = false
      @config.generation = @client.detect_generation

      configured_name = @config.name.presence
      if configured_name
        @name = configured_name
        @name_resolved = true
      else
        @name = fetch_name
      end
    end

    def query_data : Hash(Symbol, Float64 | Int64)
      response = @client.fetch_status
      response = redetect_and_retry || response unless response.status_code == 200
      data = parse_response(response)
      resolve_name_if_pending
      query_data_by_generation(data)
    end

    # A plug that was unreachable at startup was assumed to be Gen1, and a plug
    # can be swapped out for another generation at the same address. Both leave
    # the exporter querying endpoints the device does not serve, so re-probe
    # after a failed status fetch and retry once when the generation changed.
    private def redetect_and_retry : HTTP::Client::Response?
      detected = @client.detect_generation
      return if detected == @config.generation

      Log.info { "Generation for #{@config.host} is now #{detected}, retrying status fetch." }
      @config.generation = detected
      @name_resolved = false unless @config.name.presence

      @client.fetch_status
    end

    # The name is only available once the plug answers, so keep trying until a
    # settings fetch succeeds rather than reporting the host address forever.
    private def resolve_name_if_pending : Nil
      return if @name_resolved || !@config.last_request_succeeded

      @name = fetch_name
    end

    private def fetch_name : String?
      response = @client.fetch_settings
      if response.status_code == 200
        @config.last_request_succeeded = true
        @name_resolved = true
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
      in PlugGeneration::Gen1
        Gen::PlugGen1.query_data(data)
      in PlugGeneration::Gen2
        Gen::PlugGen2.query_data(data)
      end
    end

    private def extract_name_by_generation(config_json : JSON::Any) : String?
      case @config.generation
      in PlugGeneration::Gen1
        Gen::PlugGen1.extract_name(config_json)
      in PlugGeneration::Gen2
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
