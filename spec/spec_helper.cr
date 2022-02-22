require "spec"
require "kemal-basic-auth"
require "../src/shellyplug_exporter"

ENV["EXPORTER_PORT"] = "80"
ENV["SHELLYPLUG_HOSTNAME"] = "0.0.0.0"
ENV["SHELLYPLUG_PORT"] = "3000"
ENV["SHELLYPLUG_HTTP_USERNAME"] = "username"
ENV["SHELLYPLUG_HTTP_PASSWORD"] = "password"

# Start dummy server with fake response
spawn do
  basic_auth(ENV["SHELLYPLUG_HTTP_USERNAME"], ENV["SHELLYPLUG_HTTP_PASSWORD"])

  Kemal.config.env = "production"
  Kemal.config.host_binding = ENV["SHELLYPLUG_HOSTNAME"]
  Kemal.config.port = ENV["SHELLYPLUG_PORT"].to_i
  Kemal.config.logging = false

  get "/meter/0" do |env|
    env.response.content_type = "application/json"
    {
      power: 73.24,
      overpower: 0,
      is_valid: true,
      timestamp: 1645130489,
      counters: [
        72.322,
        72.007,
        72.058
      ],
      total: 243812
    }.to_json
  end

  Kemal.run
end
