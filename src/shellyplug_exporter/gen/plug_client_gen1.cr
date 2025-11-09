module ShellyplugExporter::Gen
  class PlugClientGen1
    STATUS_ENDPOINT = "/status"
    SETTINGS_ENDPOINT = "/settings"

    def self.fetch_status(client, config : ShellyplugExporter::PlugConfig) : HTTP::Client::Response
      request(client, config, STATUS_ENDPOINT)
    end

    def self.fetch_settings(client, config : ShellyplugExporter::PlugConfig) : HTTP::Client::Response
      request(client, config, SETTINGS_ENDPOINT)
    end

    def self.request(client, config : ShellyplugExporter::PlugConfig, endpoint) : HTTP::Client::Response
      client.connect_timeout = 4.seconds
      if config.auth_username && config.auth_password
        client.basic_auth(config.auth_username, config.auth_password)
      end
      client.get(endpoint)
    rescue IO::TimeoutError | Socket::Addrinfo::Error | Socket::ConnectError
      HTTP::Client::Response.new(408)
    end
  end
end
