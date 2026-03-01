module ShellyplugExporter
  # Handles HTTP communication with a single Shelly plug device.
  class PlugClient
    SHELLY_ENDPOINT = "/shelly"

    @config : PlugConfig

    def initialize(@config : PlugConfig); end

    # Detects the plug generation by probing the /shelly endpoint.
    # Gen2 devices include a "gen" field in their response.
    # Returns the detected PlugGeneration, defaulting to Gen1 on failure.
    def detect_generation : PlugGeneration
      with_client do |client|
        client.connect_timeout = 4.seconds
        response = client.get(SHELLY_ENDPOINT)

        if response.status_code == 200
          data = JSON.parse(response.body)
          gen = data["gen"]?.try(&.as_i?)
          if gen == 2
            Log.info { "Detected Gen2 for plug at #{@config.host}" }
            PlugGeneration::Gen2
          else
            Log.info { "Detected Gen1 for plug at #{@config.host}" }
            PlugGeneration::Gen1
          end
        else
          Log.warn { "Failed to detect generation for #{@config.host} (HTTP #{response.status_code}), defaulting to Gen1." }
          PlugGeneration::Gen1
        end
      end
    rescue ex : IO::TimeoutError | Socket::Addrinfo::Error | Socket::ConnectError
      Log.warn { "Could not reach #{@config.host} for generation detection: #{ex.message}. Defaulting to Gen1." }
      PlugGeneration::Gen1
    rescue ex : JSON::ParseException
      Log.warn { "Malformed JSON from #{@config.host}/shelly: #{ex.message}. Defaulting to Gen1." }
      PlugGeneration::Gen1
    end

    # Fetches the status from the plug.
    def fetch_status : HTTP::Client::Response
      with_client do |client|
        case @config.generation
        in PlugGeneration::Gen1
          Gen::PlugClientGen1.fetch_status(client, @config)
        in PlugGeneration::Gen2
          Gen::PlugClientGen2.fetch_status(client, @config)
        end
      end
    end

    # Fetches the settings/config from the plug.
    def fetch_settings : HTTP::Client::Response
      with_client do |client|
        case @config.generation
        in PlugGeneration::Gen1
          Gen::PlugClientGen1.fetch_settings(client, @config)
        in PlugGeneration::Gen2
          Gen::PlugClientGen2.fetch_settings(client, @config)
        end
      end
    end

    private def with_client(&)
      client = HTTP::Client.new(@config.host, @config.port)
      yield client
    end
  end
end
