require "../spec_helper"

include TestHelpers

describe ShellyplugExporter::Plug do
  describe "#initialize and #name" do
    before_each do
      reset_webmock_and_env
    end

    it "sets name from fetch_name when response is 200" do
      WebMock.stub(:get, "127.0.0.1:5001/settings")
             .to_return(body: "{\"name\": \"TestPlug\"}", status: 200)

      plug = ShellyplugExporter::Plug.new(build_plug_config)
      plug.name.should eq("TestPlug")
    end

    it "sets name to nil when fetch_name fails (non-200)" do
      WebMock.stub(:get, "127.0.0.1:5001/settings").to_return(status: 500)

      plug = ShellyplugExporter::Plug.new(build_plug_config(name: ""))
      plug.name.should be_nil
    end
  end

  describe "#config property" do
    it "returns the config object passed to Plug" do
      config = build_plug_config(name: "MyPlug")
      plug = ShellyplugExporter::Plug.new(config)
      plug.config.should eq(config)
    end
  end

  describe "#query_data" do
    before_each do
      reset_webmock_and_env
      WebMock.stub(:get, "127.0.0.1:5001/status")
             .with(headers: { "Authorization" => "Basic #{Base64.strict_encode("username:password").chomp}" })
             .to_return(body: File.read(Path[__DIR__, "../fixtures/valid_status.json"]))
      WebMock.stub(:get, "127.0.0.1:5001/status").to_return(status: 401)
    end

    it "returns a hash with correct values" do
      plug = ShellyplugExporter::Plug.new(build_plug_config)
      plug.query_data.should eq({
        :power => 71.71,
        :overpower => 3.50,
        :total => 785892,
        :temperature => 28.6,
        :uptime => 627711
      })
    end

    it "returns a hash with zero values when host is an invalid hostname" do
      WebMock.allow_net_connect = true
      plug = ShellyplugExporter::Plug.new(build_plug_config(host: "this-is-a-nonexistant-domain"))
      plug.query_data.should eq({
        :power => 0.0,
        :overpower => 0.0,
        :total => 0,
        :temperature => 0.0,
        :uptime => 0
      })
    end

    it "returns a hash with zero values when host is an invalid ip" do
      WebMock.allow_net_connect = true
      plug = ShellyplugExporter::Plug.new(build_plug_config(host: "255.255.255.255"))
      plug.query_data.should eq({
        :power => 0.0,
        :overpower => 0.0,
        :total => 0,
        :temperature => 0.0,
        :uptime => 0
      })
    end

    it "returns a hash with zero values when port is invalid" do
      WebMock.allow_net_connect = true
      plug = ShellyplugExporter::Plug.new(build_plug_config(port: 5003))
      plug.query_data.should eq({
        :power => 0.0,
        :overpower => 0.0,
        :total => 0,
        :temperature => 0.0,
        :uptime => 0
      })
    end

    it "returns a hash with zero values when authentication informations are invalid" do
      plug = ShellyplugExporter::Plug.new(build_plug_config(auth_password: "onlymeknowthis"))
      plug.query_data.should eq({
        :power => 0.0,
        :overpower => 0.0,
        :total => 0,
        :temperature => 0.0,
        :uptime => 0
      })
    end
  end
end
