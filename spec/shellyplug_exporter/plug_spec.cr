require "../spec_helper"

describe ShellyplugExporter::Plug do
  describe "#initialize and #name" do
    before_each do
      WebMock.reset
      DummyConfig.fill_env
    end

    it "sets name from fetch_name when response is 200" do
      WebMock.stub(:get, "127.0.0.1:5001/settings")
             .to_return(body: "{\"name\": \"TestPlug\"}", status: 200)

      plug_config = ShellyplugExporter::PlugConfig.new(
        name: "TestPlug",
        host: "127.0.0.1",
        port: 5001,
        auth_username: "username",
        auth_password: "password"
      )
      config = ShellyplugExporter::Config.new(5000, [plug_config])
      plug = ShellyplugExporter::Plug.new(plug_config)
      plug.name.should eq("TestPlug")
    end

    it "sets name to nil when fetch_name fails (non-200)" do
      WebMock.stub(:get, "127.0.0.1:5001/settings").to_return(status: 500)

      plug_config = ShellyplugExporter::PlugConfig.new(
        name: "",
        host: "127.0.0.1",
        port: 5001,
        auth_username: "username",
        auth_password: "password"
      )
      config = ShellyplugExporter::Config.new(5000, [plug_config])
      plug = ShellyplugExporter::Plug.new(plug_config)
      plug.name.should be_nil
    end
  end

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
      plug_config = ShellyplugExporter::PlugConfig.new(
        name: "TestPlug",
        host: "127.0.0.1",
        port: 5001,
        auth_username: "username",
        auth_password: "password"
      )
      config = ShellyplugExporter::Config.new(5000, [plug_config])
      plug_instance = ShellyplugExporter::Plug.new(plug_config)

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

      plug_config = ShellyplugExporter::PlugConfig.new(
        name: "TestPlug",
        host: "this-is-a-nonexistant-domain",
        port: 5001,
        auth_username: "username",
        auth_password: "password"
      )
      config = ShellyplugExporter::Config.new(5000, [plug_config])
      plug_instance = ShellyplugExporter::Plug.new(plug_config)

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

      plug_config = ShellyplugExporter::PlugConfig.new(
        name: "TestPlug",
        host: "255.255.255.255",
        port: 5001,
        auth_username: "username",
        auth_password: "password"
      )
      config = ShellyplugExporter::Config.new(5000, [plug_config])
      plug_instance = ShellyplugExporter::Plug.new(plug_config)

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

      plug_config = ShellyplugExporter::PlugConfig.new(
        name: "TestPlug",
        host: "127.0.0.1",
        port: 5003,
        auth_username: "username",
        auth_password: "password"
      )
      config = ShellyplugExporter::Config.new(5000, [plug_config])
      plug_instance = ShellyplugExporter::Plug.new(plug_config)

      plug_instance.query_data.should eq({
        :power => 0.0,
        :overpower => 0.0,
        :total => 0,
        :temperature => 0.0,
        :uptime => 0
      })
    end

    it "should return an hash with zero values when authentication informations are invalid" do
      plug_config = ShellyplugExporter::PlugConfig.new(
        name: "TestPlug",
        host: "127.0.0.1",
        port: 5001,
        auth_username: "username",
        auth_password: "onlymeknowthis"
      )
      config = ShellyplugExporter::Config.new(5000, [plug_config])
      plug_instance = ShellyplugExporter::Plug.new(plug_config)

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
