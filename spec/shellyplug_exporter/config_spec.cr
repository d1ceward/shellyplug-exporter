require "../spec_helper"

describe ShellyplugExporter::Config do
  describe "#exporter_port" do
    it "should return correct value from env" do
      ENV["EXPORTER_PORT"] = "42"
      instance = ShellyplugExporter::Config.new

      instance.exporter_port.should eq(ENV["EXPORTER_PORT"].to_i)
    end

    it "should return default value" do
      ENV.delete("EXPORTER_PORT")
      instance = ShellyplugExporter::Config.new

      instance.exporter_port.should eq(5000)
    end

    it "should return given port by setter in priority" do
      ENV["EXPORTER_PORT"] = "42"
      instance = ShellyplugExporter::Config.new
      instance.exporter_port = 21

      instance.exporter_port.should eq(21)
    end
  end

  describe "#plug_host" do
    it "should return correct value from env" do
      ENV["SHELLYPLUG_HOST"] = "theworldsworstwebsiteever.com"
      instance = ShellyplugExporter::Config.new

      instance.plug_host.should eq(ENV["SHELLYPLUG_HOST"])
    end

    it "should return default value" do
      ENV.delete("SHELLYPLUG_HOST")
      instance = ShellyplugExporter::Config.new

      instance.plug_host.should eq("192.168.33.1")
    end

    it "should return given plug host by setter in priority" do
      ENV["SHELLYPLUG_HOST"] = "theworldsworstwebsiteever.com"
      instance = ShellyplugExporter::Config.new
      instance.plug_host = "www.nyan.cat"

      instance.plug_host.should eq("www.nyan.cat")
    end
  end

  describe "#plug_port" do
  it "should return correct value from env" do
    ENV["SHELLYPLUG_PORT"] = "666"
    instance = ShellyplugExporter::Config.new

    instance.plug_port.should eq(ENV["SHELLYPLUG_PORT"].to_i)
  end

  it "should return default value" do
    ENV.delete("SHELLYPLUG_PORT")
    instance = ShellyplugExporter::Config.new

    instance.plug_port.should eq(80)
  end

  it "should return given plug port by setter in priority" do
    ENV["SHELLYPLUG_PORT"] = "666"
    instance = ShellyplugExporter::Config.new
    instance.plug_port = 999

    instance.plug_port.should eq(999)
  end
end

  describe "#plug_auth_username" do
    it "should return correct value from env" do
      ENV["SHELLYPLUG_AUTH_USERNAME"] = "xxr34p3r"
      instance = ShellyplugExporter::Config.new

      instance.plug_auth_username.should eq(ENV["SHELLYPLUG_AUTH_USERNAME"])
    end

    it "should return nil by default" do
      ENV.delete("SHELLYPLUG_AUTH_USERNAME")
      instance = ShellyplugExporter::Config.new

      instance.plug_auth_username.should be_nil
    end

    it "should return given plug http auth username by setter in priority" do
      ENV["SHELLYPLUG_AUTH_USERNAME"] = "xxr34p3r"
      instance = ShellyplugExporter::Config.new
      instance.plug_auth_username = "Hellwalker"

      instance.plug_auth_username.should eq("Hellwalker")
    end
  end

  describe "#plug_auth_password" do
    it "should return correct value from env" do
      ENV["SHELLYPLUG_AUTH_PASSWORD"] = "123456789*"
      instance = ShellyplugExporter::Config.new

      instance.plug_auth_password.should eq(ENV["SHELLYPLUG_AUTH_PASSWORD"])
    end

    it "should return nil by default" do
      ENV.delete("SHELLYPLUG_AUTH_PASSWORD")
      instance = ShellyplugExporter::Config.new

      instance.plug_auth_password.should be_nil
    end

    it "should return given plug http auth username by setter in priority" do
      ENV["SHELLYPLUG_AUTH_PASSWORD"] = "123456789*"
      instance = ShellyplugExporter::Config.new
      instance.plug_auth_password = "FBISurveillanceVan"

      instance.plug_auth_password.should eq("FBISurveillanceVan")
    end
  end
end
