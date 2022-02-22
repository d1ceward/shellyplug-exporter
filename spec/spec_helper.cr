ENV["CRYSTAL_SPEC_CONTEXT"] = "true"

require "kemal-basic-auth"
require "spec"
require "spec-kemal"
require "../src/shellyplug_exporter"

module DummyConfig
  EXPORTER_PORT = "5000"
  PLUG_HOST = "127.0.0.1"
  PLUG_PORT = "5001"
  PLUG_AUTH_USERNAME = "username"
  PLUG_AUTH_PASSWORD = "password"

  def self.fill_env
    ENV["EXPORTER_PORT"] = EXPORTER_PORT
    ENV["SHELLYPLUG_HOST"] = PLUG_HOST
    ENV["SHELLYPLUG_PORT"] = PLUG_PORT
    ENV["SHELLYPLUG_AUTH_USERNAME"] = PLUG_AUTH_USERNAME
    ENV["SHELLYPLUG_AUTH_PASSWORD"] = PLUG_AUTH_PASSWORD
  end
end

# Start dummy server with fake response
spawn do
  basic_auth(DummyConfig::PLUG_AUTH_USERNAME, DummyConfig::PLUG_AUTH_PASSWORD)

  Kemal.config.env = "production"
  Kemal.config.host_binding = DummyConfig::PLUG_HOST
  Kemal.config.port = DummyConfig::PLUG_PORT.to_i
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
