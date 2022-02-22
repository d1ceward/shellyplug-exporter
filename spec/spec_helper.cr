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

  get "/status" do |env|
    env.response.content_type = "application/json"
    {
      wifi_sta: {
        connected: true,
        ssid: "Super-Wifi",
        ip: "192.168.33.1",
        rssi: -49
      },
      cloud: {
        enabled: false,
        connected: false
      },
      mqtt: {
        connected: false
      },
      time: "21:17",
      unixtime: 1645561076,
      serial: 1,
      has_update: false,
      mac: "111111111111",
      cfg_changed_cnt: 9,
      actions_stats: {
        skipped: 0
      },
      relays: [
        {
          ison: true,
          has_timer: false,
          timer_started: 0,
          timer_duration: 0,
          timer_remaining: 0,
          overpower: false,
          source: "http"
        }
      ],
      meters: [
        {
          power: 71.71,
          overpower: 3.50,
          is_valid: true,
          timestamp: 1645564676,
          counters: [
            71.78,
            72.206,
            71.978
          ],
          total: 785892
        }
      ],
      temperature: 28.6,
      overtemperature: false,
      tmp: {
        tC: 28.6,
        tF: 83.48,
        is_valid: true
      },
      update: {
        status: "idle",
        has_update: false,
        new_version: "20220209-094058/v1.11.8-g8c7bb8d",
        old_version: "20220209-094058/v1.11.8-g8c7bb8d"
      },
      ram_total: 51264,
      ram_free: 39420,
      fs_size: 233681,
      fs_free: 166413,
      uptime: 627711
    }.to_json
  end

  Kemal.run
end
