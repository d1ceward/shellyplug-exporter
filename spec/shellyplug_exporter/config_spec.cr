require "../spec_helper"

include TestHelpers

describe ShellyplugExporter::Config do
  before_each { reset_webmock_and_env }

  describe "#exporter_port" do
    it "should return correct value from env" do
      ENV["EXPORTER_PORT"] = "42"

      plug_config = ShellyplugExporter::PlugConfig.new("TestPlug", "127.0.0.1", 5001)
      instance = ShellyplugExporter::Config.new(ENV["EXPORTER_PORT"].to_i, [plug_config])

      instance.exporter_port.should eq(ENV["EXPORTER_PORT"].to_i)
    end

    it "should return default value" do
      ENV.delete("EXPORTER_PORT")

      plug_config = ShellyplugExporter::PlugConfig.new("TestPlug", "127.0.0.1", 5001)
      instance = ShellyplugExporter::Config.new(5000, [plug_config])

      instance.exporter_port.should eq(5000)
    end

    it "should return given port by setter in priority" do
      ENV["EXPORTER_PORT"] = "42"

      plug_config = ShellyplugExporter::PlugConfig.new("TestPlug", "127.0.0.1", 5001)
      instance = ShellyplugExporter::Config.new(42, [plug_config])
      instance.exporter_port = 21

      instance.exporter_port.should eq(21)
    end
  end

  describe "#plug_host" do
    it "should return correct value from env" do
      ENV["SHELLYPLUG_HOST"] = "theworldsworstwebsiteever.com"

      plug_config = ShellyplugExporter::PlugConfig.new("TestPlug", ENV["SHELLYPLUG_HOST"], 5001)
      instance = ShellyplugExporter::Config.new(5000, [plug_config])

      instance.plugs.first.host.should eq(ENV["SHELLYPLUG_HOST"])
    end

    it "should return default value" do
      ENV.delete("SHELLYPLUG_HOST")

      plug_config = ShellyplugExporter::PlugConfig.new("TestPlug", "192.168.33.1", 5001)
      instance = ShellyplugExporter::Config.new(5000, [plug_config])

      instance.plugs.first.host.should eq("192.168.33.1")
    end

    it "should return given plug host by setter in priority" do
      ENV["SHELLYPLUG_HOST"] = "theworldsworstwebsiteever.com"

      plug_config = ShellyplugExporter::PlugConfig.new("TestPlug", "theworldsworstwebsiteever.com", 5001)
      instance = ShellyplugExporter::Config.new(5000, [plug_config])
      instance.plugs.first.host = "www.nyan.cat"

      instance.plugs.first.host.should eq("www.nyan.cat")
    end
  end

  describe "#plug_port" do
    it "should return correct value from env" do
      ENV["SHELLYPLUG_PORT"] = "666"

      plug_config = ShellyplugExporter::PlugConfig.new("TestPlug", "127.0.0.1", ENV["SHELLYPLUG_PORT"].to_i)
      instance = ShellyplugExporter::Config.new(5000, [plug_config])

      instance.plugs.first.port.should eq(ENV["SHELLYPLUG_PORT"].to_i)
    end

    it "should return default value" do
      ENV.delete("SHELLYPLUG_PORT")

      plug_config = ShellyplugExporter::PlugConfig.new("TestPlug", "127.0.0.1", 80)
      instance = ShellyplugExporter::Config.new(5000, [plug_config])

      instance.plugs.first.port.should eq(80)
    end

    it "should return given plug port by setter in priority" do
      ENV["SHELLYPLUG_PORT"] = "666"

      plug_config = ShellyplugExporter::PlugConfig.new("TestPlug", "127.0.0.1", 666)
      instance = ShellyplugExporter::Config.new(5000, [plug_config])
      instance.plugs.first.port = 999

      instance.plugs.first.port.should eq(999)
    end
  end

  describe "#plug_auth_username" do
    it "should return correct value from env" do
      ENV["SHELLYPLUG_AUTH_USERNAME"] = "xxr34p3r"

      plug_config = ShellyplugExporter::PlugConfig.new(
        "TestPlug",
        "127.0.0.1",
        5001,
        ENV["SHELLYPLUG_AUTH_USERNAME"]
      )
      instance = ShellyplugExporter::Config.new(5000, [plug_config])

      instance.plugs.first.auth_username.should eq(ENV["SHELLYPLUG_AUTH_USERNAME"])
    end

    it "should return nil by default" do
      ENV.delete("SHELLYPLUG_AUTH_USERNAME")

      plug_config = ShellyplugExporter::PlugConfig.new("TestPlug", "127.0.0.1", 5001)
      instance = ShellyplugExporter::Config.new(5000, [plug_config])

      instance.plugs.first.auth_username.should be_nil
    end

    it "should return given plug http auth username by setter in priority" do
      ENV["SHELLYPLUG_AUTH_USERNAME"] = "xxr34p3r"

      plug_config = ShellyplugExporter::PlugConfig.new(
        "TestPlug",
        "127.0.0.1",
        5001,
        ENV["SHELLYPLUG_AUTH_USERNAME"]
      )
      instance = ShellyplugExporter::Config.new(5000, [plug_config])
      instance.plugs.first.auth_username = "Hellwalker"

      instance.plugs.first.auth_username.should eq("Hellwalker")
    end
  end

  describe "#plug_auth_password" do
    it "should return correct value from env" do
      ENV["SHELLYPLUG_AUTH_PASSWORD"] = "123456789*"

      plug_config = ShellyplugExporter::PlugConfig.new(
        "TestPlug",
        "127.0.0.1",
        5001,
        nil,
        ENV["SHELLYPLUG_AUTH_PASSWORD"]
      )
      instance = ShellyplugExporter::Config.new(5000, [plug_config])

      instance.plugs.first.auth_password.should eq(ENV["SHELLYPLUG_AUTH_PASSWORD"])
    end

    it "should return nil by default" do
      ENV.delete("SHELLYPLUG_AUTH_PASSWORD")

      plug_config = ShellyplugExporter::PlugConfig.new("TestPlug", "127.0.0.1", 5001)
      instance = ShellyplugExporter::Config.new(5000, [plug_config])

      instance.plugs.first.auth_password.should be_nil
    end

    it "should return given plug http auth username by setter in priority" do
      ENV["SHELLYPLUG_AUTH_PASSWORD"] = "123456789*"

      plug_config = ShellyplugExporter::PlugConfig.new(
        "TestPlug",
        "127.0.0.1",
        5001,
        nil,
        ENV["SHELLYPLUG_AUTH_PASSWORD"]
)
      instance = ShellyplugExporter::Config.new(5000, [plug_config])
      instance.plugs.first.auth_password = "FBISurveillanceVan"

      instance.plugs.first.auth_password.should eq("FBISurveillanceVan")
    end
  end

  describe "Config.load YAML variable interpolation" do
    it "interpolates ${EXPORTER_PORT} from env" do
      ENV["EXPORTER_PORT"] = "12345"

      path = "spec/fixtures/interpolation_env.yaml"
      config = ShellyplugExporter::Config.load(path)

      config.exporter_port.should eq(12345)
    end

    it "uses default for ${EXPORTER_PORT:-9999} if not set" do
      ENV.delete("EXPORTER_PORT")

      path = "spec/fixtures/interpolation_env_default.yaml"
      config = ShellyplugExporter::Config.load(path)

      config.exporter_port.should eq(9999)
    end

    it "prints error and exits for ${EXPORTER_PORT:?required}" do
      ENV.delete("EXPORTER_PORT")

      path = "spec/fixtures/interpolation_env_required.yaml"
      output = IO::Memory.new
      status = Process.run(
        ["crystal", "eval", "require \"./src/shellyplug_exporter\"; ShellyplugExporter::Config.load(\"#{path}\")"],
        output: output,
        error: output
      )
      output.rewind

      output.gets_to_end.should contain("Environment variable EXPORTER_PORT is required")
      status.exit_code.should eq(1)
    end

    it "interpolates plug host from env" do
      ENV["SHELLYPLUG_HOST"] = "myhost"

      path = "spec/fixtures/interpolation_env_host.yaml"
      config = ShellyplugExporter::Config.load(path)

      config.plugs.first.host.should eq("myhost")
    end
  end
end
