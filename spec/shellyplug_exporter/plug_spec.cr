require "../spec_helper"

describe ShellyplugExporter::Plug do

  describe "#query_data" do
    before_each { DummyConfig.fill_env }

    it "should return an hash with correct values" do
      config = ShellyplugExporter::Config.new
      plug_instance = ShellyplugExporter::Plug.new(config)

      plug_instance.query_data.should eq({ :power => 73.24, :total => 243812 })
    end

    it "should return an hash with zero values when host is an invalid hostname" do
      ENV["SHELLYPLUG_HOST"] = "this-is-a-nonexistant-domain"
      config = ShellyplugExporter::Config.new
      plug_instance = ShellyplugExporter::Plug.new(config)

      plug_instance.query_data.should eq({ :power => 0_f64, :total => 0_i64 })
    end

    it "should return an hash with zero values when host is an invalid ip" do
      ENV["SHELLYPLUG_HOST"] = "255.255.255.255"
      config = ShellyplugExporter::Config.new
      plug_instance = ShellyplugExporter::Plug.new(config)

      plug_instance.query_data.should eq({ :power => 0_f64, :total => 0_i64 })
    end

    it "should return an hash with zero values when port is invalid" do
      ENV["SHELLYPLUG_PORT"] = "5003"
      config = ShellyplugExporter::Config.new
      plug_instance = ShellyplugExporter::Plug.new(config)

      plug_instance.query_data.should eq({ :power => 0_f64, :total => 0_i64 })
    end

    it "should return an hash with zero values when authentication informations are invalid" do
      ENV["SHELLYPLUG_AUTH_PASSWORD"] = "onlymeknowthis"
      config = ShellyplugExporter::Config.new
      plug_instance = ShellyplugExporter::Plug.new(config)

      plug_instance.query_data.should eq({ :power => 0_f64, :total => 0_i64 })
    end
  end
end
