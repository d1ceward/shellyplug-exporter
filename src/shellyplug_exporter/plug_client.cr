module ShellyplugExporter
  # Handles HTTP communication with the Shelly plug device.
  class PlugClient
    STATUS_ENDPOINT = "/status"
    SETTINGS_ENDPOINT = "/settings"

    def initialize(@config : Config)
    end

    def fetch_status : HTTP::Client::Response
      request(STATUS_ENDPOINT)
    end

    def fetch_settings : HTTP::Client::Response
      request(SETTINGS_ENDPOINT)
    end

    private def request(endpoint : String) : HTTP::Client::Response
      client = HTTP::Client.new(@config.plug_host, @config.plug_port)
      client.connect_timeout = 4.seconds

      if @config.plug_auth_username && @config.plug_auth_password
        client.basic_auth(@config.plug_auth_username, @config.plug_auth_password)
      end

      client.get(endpoint)
    rescue IO::TimeoutError | Socket::Addrinfo::Error | Socket::ConnectError
      HTTP::Client::Response.new(408)
    end
  end
end
