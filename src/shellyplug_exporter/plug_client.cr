module ShellyplugExporter
  # Handles HTTP communication with a single Shelly plug device.
  class PlugClient
    @config : PlugConfig

    def initialize(@config : PlugConfig); end

    # Fetches the status from the plug.
    def fetch_status : HTTP::Client::Response
      with_client do |client|
        case @config.generation
        when PlugGeneration::Gen1
          Gen::PlugClientGen1.fetch_status(client, @config)
        when PlugGeneration::Gen2
          Gen::PlugClientGen2.fetch_status(client, @config)
        else
          HTTP::Client::Response.new(500)
        end
      end
    end

    # Fetches the settings/config from the plug.
    def fetch_settings : HTTP::Client::Response
      with_client do |client|
        case @config.generation
        when PlugGeneration::Gen1
          Gen::PlugClientGen1.fetch_settings(client, @config)
        when PlugGeneration::Gen2
          Gen::PlugClientGen2.fetch_settings(client, @config)
        else
          HTTP::Client::Response.new(500)
        end
      end
    end

    private def with_client(&)
      client = HTTP::Client.new(@config.host, @config.port)
      yield client
    end
  end
end
