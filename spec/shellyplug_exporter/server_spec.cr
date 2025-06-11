require "../spec_helper"
require "http/client"
require "json"

describe ShellyplugExporter::Server do
  before_each do
    WebMock.reset
    WebMock.allow_net_connect = true
    WebMock.stub(:get, "127.0.0.1:5001/status")
           .with(headers: { "Authorization" => "Basic #{Base64.strict_encode("username:password").chomp}" })
           .to_return(body: File.read(Path[__DIR__, "../fixtures/valid_status.json"]))
    WebMock.stub(:get, "127.0.0.1:5001/settings")
           .to_return(body: "{\"name\": \"testplug\"}", status: 200)
    DummyConfig.fill_env
  end

  it "responds with prometheus metrics on /metrics" do
    config = ShellyplugExporter::Config.new
    server = ShellyplugExporter::Server.new(config)

    spawn { server.run }

    # Allow some time for the server to start
    sleep(100.milliseconds)

    response = HTTP::Client.get("http://127.0.0.1:#{config.exporter_port}/metrics")
    response.status_code.should eq 200
    response.body.should contain "shellyplug_power{name=\"testplug\"} 71.71"
    response.body.should contain "# HELP shellyplug_power"

    server.stop
  end

  it "responds with 200 OK on /health if last_request_succeded is true" do
    config = ShellyplugExporter::Config.new
    config.last_request_succeded = true
    server = ShellyplugExporter::Server.new(config)

    spawn { server.run }

    # Allow some time for the server to start
    sleep(100.milliseconds)

    response = HTTP::Client.get("http://127.0.0.1:#{config.exporter_port}/health")
    response.status_code.should eq 200
    response.body.should contain "OK"

    server.stop
  end

  it "responds with 503 on /health if last_request_succeded is false" do
    config = ShellyplugExporter::Config.new
    config.last_request_succeded = false
    server = ShellyplugExporter::Server.new(config)

    spawn { server.run }

    # Allow some time for the server to start
    sleep(100.milliseconds)

    response = HTTP::Client.get("http://127.0.0.1:#{config.exporter_port}/health")
    response.status_code.should eq 503
    response.body.should contain "ERROR"

    server.stop
  end

  it "responds with 404 on unknown endpoint" do
    config = ShellyplugExporter::Config.new
    server = ShellyplugExporter::Server.new(config)

    spawn { server.run }

    # Allow some time for the server to start
    sleep(100.milliseconds)

    response = HTTP::Client.get("http://127.0.0.1:#{config.exporter_port}/unknown")
    response.status_code.should eq 404
    response.body.should contain "Not found"

    server.stop
  end
end
