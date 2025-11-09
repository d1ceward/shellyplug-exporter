module ShellyplugExporter::Gen
  class PlugClientGen2
    RPC_STATUS_ENDPOINT = "/rpc/Shelly.GetStatus"
    RPC_CONFIG_ENDPOINT = "/rpc/Shelly.GetConfig"

    def self.fetch_status(client, config : ShellyplugExporter::PlugConfig) : HTTP::Client::Response
      request(client, config, RPC_STATUS_ENDPOINT)
    end

    def self.fetch_settings(client, config : ShellyplugExporter::PlugConfig) : HTTP::Client::Response
      request(client, config, RPC_CONFIG_ENDPOINT)
    end

    def self.request(client, config : ShellyplugExporter::PlugConfig, endpoint) : HTTP::Client::Response
      client.connect_timeout = 4.seconds

      username = config.auth_username
      password = config.auth_password
      if username && password
        response = client.get(endpoint)

        if response.status_code == 401 && (www_auth = response.headers["WWW-Authenticate"]?)
          auth_header = ShellyplugExporter::Gen::Helper::DigestAuthHelper.digest_authorization(
            username,
            password,
            "GET",
            endpoint,
            www_auth
          )

          # Use a one-time before_request hook for this request only
          client.before_request do |request|
            request.headers["Authorization"] = auth_header
          end

          response = client.get(endpoint)
        end

        response
      else
        client.get(endpoint)
      end
    rescue IO::TimeoutError | Socket::Addrinfo::Error | Socket::ConnectError
      HTTP::Client::Response.new(408)
    end
  end
end
