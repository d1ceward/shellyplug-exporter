require "../spec_helper"
require "http/client"
require "json"

include TestHelpers

SERVER_STARTUP_DELAY = 100.milliseconds

describe ShellyplugExporter::Server do
  server = nil

  before_each do
    reset_webmock_and_env
    WebMock.allow_net_connect = true
    WebMock.stub(:get, "127.0.0.1:5001/status")
      .with(headers: { "Authorization" => "Basic #{Base64.strict_encode("username:password").chomp}" })
      .to_return(body: File.read(Path[__DIR__, "../fixtures/valid_status.json"]))
    WebMock.stub(:get, "127.0.0.1:5001/settings")
      .to_return(body: "{\"name\": \"TestPlug\"}", status: 200)
    server = nil
  end

  after_each do
    server.try(&.stop)
  end

  it "responds with prometheus metrics on /metrics" do
    result = build_server
    server = result[:server]
    config = result[:config]
    spawn { server.try(&.run) }
    sleep(SERVER_STARTUP_DELAY)
    response = HTTP::Client.get("http://127.0.0.1:#{config.exporter_port}/metrics")
    response.status_code.should eq 200
    response.body.should contain "shellyplug_power{name=\"TestPlug\"} 71.71"
    response.body.should contain "# HELP shellyplug_power"
  end

  it "responds with 200 OK on /health if last_request_succeded is true" do
    result = build_server(true)
    server = result[:server]
    config = result[:config]
    spawn { server.try(&.run) }
    sleep(SERVER_STARTUP_DELAY)
    response = HTTP::Client.get("http://127.0.0.1:#{config.exporter_port}/health")
    response.status_code.should eq 200
    response.body.should contain "OK"
  end

  it "responds with 503 on /health if last_request_succeded is false" do
    result = build_server(false)
    server = result[:server]
    config = result[:config]
    spawn { server.try(&.run) }
    sleep(SERVER_STARTUP_DELAY)
    response = HTTP::Client.get("http://127.0.0.1:#{config.exporter_port}/health")
    response.status_code.should eq 503
    response.body.should contain "ERROR"
  end

  it "responds with 404 on unknown endpoint" do
    result = build_server
    server = result[:server]
    config = result[:config]
    spawn { server.try(&.run) }
    sleep(SERVER_STARTUP_DELAY)
    response = HTTP::Client.get("http://127.0.0.1:#{config.exporter_port}/unknown")
    response.status_code.should eq 404
    response.body.should contain "Not found"
  end
end
