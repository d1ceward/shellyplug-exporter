require "../spec_helper"

describe ShellyplugExporter::Plug do
  describe "#query_data" do
    before_each do
      WebMock.reset
      WebMock.stub(:get, "127.0.0.1:5001/status")
             .with(headers: { "Authorization" => "Basic #{Base64.strict_encode("username:password").chomp}" })
             .to_return(body: File.read(Path[__DIR__, "../fixtures/valid_status.json"]))
      WebMock.stub(:get, "127.0.0.1:5001/status").to_return(status: 401)

      DummyConfig.fill_env
    end

    it "should return an hash with correct values" do
      config = ShellyplugExporter::Config.new
      plug_instance = ShellyplugExporter::Plug.new(config)

      plug_instance.query_data.should eq({
        :power => 71.71,
        :overpower => 3.50,
        :total => 785892,
        :temperature => 28.6,
        :uptime => 627711
      })
    end

    it "should return an hash with zero values when host is an invalid hostname" do
      WebMock.allow_net_connect = true

      ENV["SHELLYPLUG_HOST"] = "this-is-a-nonexistant-domain"
      config = ShellyplugExporter::Config.new
      plug_instance = ShellyplugExporter::Plug.new(config)

      plug_instance.query_data.should eq({
        :power => 0.0,
        :overpower => 0.0,
        :total => 0,
        :temperature => 0.0,
        :uptime => 0
      })
    end

    it "should return an hash with zero values when host is an invalid ip" do
      WebMock.allow_net_connect = true

      ENV["SHELLYPLUG_HOST"] = "255.255.255.255"
      config = ShellyplugExporter::Config.new
      plug_instance = ShellyplugExporter::Plug.new(config)

      plug_instance.query_data.should eq({
        :power => 0.0,
        :overpower => 0.0,
        :total => 0,
        :temperature => 0.0,
        :uptime => 0
      })
    end

    it "should return an hash with zero values when port is invalid" do
      WebMock.allow_net_connect = true

      ENV["SHELLYPLUG_PORT"] = "5003"
      config = ShellyplugExporter::Config.new
      plug_instance = ShellyplugExporter::Plug.new(config)

      plug_instance.query_data.should eq({
        :power => 0.0,
        :overpower => 0.0,
        :total => 0,
        :temperature => 0.0,
        :uptime => 0
      })
    end

    it "should return an hash with zero values when authentication informations are invalid" do
      ENV["SHELLYPLUG_AUTH_PASSWORD"] = "onlymeknowthis"
      config = ShellyplugExporter::Config.new
      plug_instance = ShellyplugExporter::Plug.new(config)

      plug_instance.query_data.should eq({
        :power => 0.0,
        :overpower => 0.0,
        :total => 0,
        :temperature => 0.0,
        :uptime => 0
      })
    end
  end
end
