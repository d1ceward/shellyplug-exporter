require "../spec_helper"

describe ShellyplugExporter::Plug do

  describe "#query_data" do
    valid_data =  {
      :power => 71.71,
      :overpower => 3.50,
      :total => 785892,
      :temperature => 28.6,
      :uptime => 627711
    }
    invalid_data = { :power => 0.0, :overpower => 0.0, :total => 0, :temperature => 0.0, :uptime => 0 }

    before_each { DummyConfig.fill_env }

    it "should return an hash with correct values" do
      config = ShellyplugExporter::Config.new
      plug_instance = ShellyplugExporter::Plug.new(config)

      plug_instance.query_data.should eq(valid_data)
    end

    it "should return an hash with zero values when host is an invalid hostname" do
      ENV["SHELLYPLUG_HOST"] = "this-is-a-nonexistant-domain"
      config = ShellyplugExporter::Config.new
      plug_instance = ShellyplugExporter::Plug.new(config)

      plug_instance.query_data.should eq(invalid_data)
    end

    it "should return an hash with zero values when host is an invalid ip" do
      ENV["SHELLYPLUG_HOST"] = "255.255.255.255"
      config = ShellyplugExporter::Config.new
      plug_instance = ShellyplugExporter::Plug.new(config)

      plug_instance.query_data.should eq(invalid_data)
    end

    it "should return an hash with zero values when port is invalid" do
      ENV["SHELLYPLUG_PORT"] = "5003"
      config = ShellyplugExporter::Config.new
      plug_instance = ShellyplugExporter::Plug.new(config)

      plug_instance.query_data.should eq(invalid_data)
    end

    it "should return an hash with zero values when authentication informations are invalid" do
      ENV["SHELLYPLUG_AUTH_PASSWORD"] = "onlymeknowthis"
      config = ShellyplugExporter::Config.new
      plug_instance = ShellyplugExporter::Plug.new(config)

      plug_instance.query_data.should eq(invalid_data)
    end
  end
end
