ENV["CRYSTAL_SPEC_CONTEXT"] = "true"

require "spec"
require "webmock"
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
