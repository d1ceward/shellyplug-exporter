module ShellyplugExporter::Gen
  class PlugClientGen1
    STATUS_ENDPOINT = "/status"
    SETTINGS_ENDPOINT = "/settings"

    def self.fetch_status(client, config)
      request(client, config, STATUS_ENDPOINT)
    end

    def self.fetch_settings(client, config)
      request(client, config, SETTINGS_ENDPOINT)
    end

    def self.request(client, config, endpoint)
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
