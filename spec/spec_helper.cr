ENV["CRYSTAL_SPEC_CONTEXT"] = "true"

require "spec"
require "webmock"
require "../src/shellyplug_exporter"

module DummyConfig
  def self.fill_env
    ENV["EXPORTER_PORT"] = "5000"
    ENV["SHELLYPLUG_HOST"] = "127.0.0.1"
    ENV["SHELLYPLUG_PORT"] = "5001"
    ENV["SHELLYPLUG_AUTH_USERNAME"] = "username"
    ENV["SHELLYPLUG_AUTH_PASSWORD"] = "password"
  end
end
