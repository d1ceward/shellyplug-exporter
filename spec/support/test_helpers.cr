module TestHelpers
  # Sets environment variables for dummy config
  def fill_env
    ENV["EXPORTER_PORT"] = "5000"
    ENV["SHELLYPLUG_HOST"] = "127.0.0.1"
    ENV["SHELLYPLUG_PORT"] = "5001"
    ENV["SHELLYPLUG_AUTH_USERNAME"] = "username"
    ENV["SHELLYPLUG_AUTH_PASSWORD"] = "password"
  end

  # Resets WebMock and fills environment variables
  def reset_webmock_and_env
    WebMock.reset
    fill_env
  end

  # Helper to create PlugConfig
  def build_plug_config(
    name : String = "TestPlug",
    host : String = "127.0.0.1",
    port : Int32 = 5001,
    auth_username : String = "username",
    auth_password : String = "password",
    last_request_succeeded = nil
  )
    ShellyplugExporter::PlugConfig.new(
      name: name,
      host: host,
      port: port,
      auth_username: auth_username,
      auth_password: auth_password,
      last_request_succeeded: last_request_succeeded
    )
  end

  # Helper to create Server and Config
  def build_server(last_request_succeeded = nil)
    plug_config = build_plug_config(last_request_succeeded: last_request_succeeded)
    config = ShellyplugExporter::Config.new(5000, [plug_config])
    plug = ShellyplugExporter::Plug.new(plug_config)
    server = ShellyplugExporter::Server.new([plug], config.exporter_port)

    { server: server, config: config }
  end
end
