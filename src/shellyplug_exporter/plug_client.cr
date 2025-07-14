module ShellyplugExporter
  # Handles HTTP communication with a single Shelly plug device.
  class PlugClient
    STATUS_ENDPOINT = "/status"
    SETTINGS_ENDPOINT = "/settings"

    @config : PlugConfig

    def initialize(@config : PlugConfig); end

    # Fetches the status from the plug.
    def fetch_status : HTTP::Client::Response
      request(STATUS_ENDPOINT)
    end

    # Fetches the settings from the plug.
    def fetch_settings : HTTP::Client::Response
      request(SETTINGS_ENDPOINT)
    end

    private def request(endpoint : String) : HTTP::Client::Response
      client = HTTP::Client.new(@config.host, @config.port)

      # Set timeout for the request
      client.connect_timeout = 4.seconds

      if @config.auth_username && @config.auth_password
        client.basic_auth(@config.auth_username, @config.auth_password)
      end

      client.get(endpoint)
    rescue IO::TimeoutError | Socket::Addrinfo::Error | Socket::ConnectError
      HTTP::Client::Response.new(408)
    end
  end
end
