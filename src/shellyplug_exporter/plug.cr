module ShellyplugExporter
  class Plug
    def initialize
      @hostname = ENV["SHELLYPLUG_HOSTNAME"]?
      @port = ENV["SHELLYPLUG_PORT"]?.presence || "80"
      @http_username = ENV["SHELLYPLUG_HTTP_USERNAME"]?
      @http_password = ENV["SHELLYPLUG_HTTP_PASSWORD"]?
    end

    def fetch_plug_data
      raise MissingHostname.new("Missing hostname environement variable") unless @hostname

      client = HTTP::Client.new(@hostname.not_nil!, @port.to_i)

      # Enable http auth if username and password are present
      client.basic_auth(@http_username, @http_password) if @http_username && @http_password

      response = client.get("/meter/0")
      raise InvalidCredentials.new("Invalid credentials") if response.status_code == 401
      return JSON.parse("{}") unless response.status_code == 200

      JSON.parse(response.body)
    end
  end
end
