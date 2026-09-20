require "../spec_helper"

include TestHelpers

describe ShellyplugExporter::PlugClient do
  before_each { reset_webmock_and_env }

  describe "#detect_generation" do
    it "returns Gen2 when /shelly advertises gen 2" do
      stub_shelly_gen2
      client = ShellyplugExporter::PlugClient.new(build_plug_config)

      client.detect_generation.should eq(ShellyplugExporter::PlugGeneration::Gen2)
    end

    it "returns Gen1 when /shelly omits the gen field" do
      stub_shelly_gen1
      client = ShellyplugExporter::PlugClient.new(build_plug_config)

      client.detect_generation.should eq(ShellyplugExporter::PlugGeneration::Gen1)
    end
  end

  describe "#fetch_status" do
    it "queries the Gen1 endpoint with basic auth" do
      WebMock.stub(:get, "127.0.0.1:5001/status")
             .with(headers: { "Authorization" => "Basic #{Base64.strict_encode("username:password")}" })
             .to_return(body: "{}", status: 200)

      client = ShellyplugExporter::PlugClient.new(build_plug_config)
      client.fetch_status.status_code.should eq(200)
    end

    it "queries the Gen2 RPC endpoint" do
      WebMock.stub(:get, "127.0.0.1:5001/rpc/Shelly.GetStatus").to_return(body: "{}", status: 200)

      config = build_plug_config(generation: ShellyplugExporter::PlugGeneration::Gen2)
      ShellyplugExporter::PlugClient.new(config).fetch_status.status_code.should eq(200)
    end

    it "retries a Gen2 request with a digest header after a 401" do
      seen_authorizations = [] of String?
      WebMock.stub(:get, "127.0.0.1:5001/rpc/Shelly.GetStatus").to_return do |request|
        seen_authorizations << request.headers["Authorization"]?

        if seen_authorizations.size == 1
          HTTP::Client::Response.new(
            401,
            headers: HTTP::Headers{
              "WWW-Authenticate" => %(Digest qop="auth", realm="shelly", nonce="abc", algorithm=SHA-256)
            }
          )
        else
          HTTP::Client::Response.new(200, body: "{}")
        end
      end

      config = build_plug_config(generation: ShellyplugExporter::PlugGeneration::Gen2)
      response = ShellyplugExporter::PlugClient.new(config).fetch_status

      response.status_code.should eq(200)
      seen_authorizations.size.should eq(2)
      seen_authorizations[0].should be_nil
      seen_authorizations[1].to_s.should start_with(%(Digest username="username"))
    end

    it "returns 408 when the plug is unreachable" do
      WebMock.allow_net_connect = true
      config = build_plug_config(host: "this-is-a-nonexistant-domain")

      ShellyplugExporter::PlugClient.new(config).fetch_status.status_code.should eq(408)
    end
  end
end
