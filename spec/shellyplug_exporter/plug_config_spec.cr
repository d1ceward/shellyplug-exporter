require "../spec_helper"

describe ShellyplugExporter::PlugConfig do
  it "initializes with required fields" do
    config = ShellyplugExporter::PlugConfig.new("plug1", "192.168.1.2", 80)
    config.name.should eq "plug1"
    config.host.should eq "192.168.1.2"
    config.port.should eq 80
    config.auth_username.should be_nil
    config.auth_password.should be_nil
    config.last_request_succeeded.should be_nil
  end

  it "initializes with all fields" do
    config = ShellyplugExporter::PlugConfig.new("plug2", "192.168.1.3", 8080, "user", "pass", true)
    config.name.should eq "plug2"
    config.host.should eq "192.168.1.3"
    config.port.should eq 8080
    config.auth_username.should eq "user"
    config.auth_password.should eq "pass"
    config.last_request_succeeded.should eq true
  end

  it "allows updating properties" do
    config = ShellyplugExporter::PlugConfig.new("plug3", "192.168.1.4", 8081)
    config.name = "plug3-renamed"
    config.host = "192.168.1.44"
    config.port = 8082
    config.auth_username = "admin"
    config.auth_password = "secret"
    config.last_request_succeeded = false
    config.name.should eq "plug3-renamed"
    config.host.should eq "192.168.1.44"
    config.port.should eq 8082
    config.auth_username.should eq "admin"
    config.auth_password.should eq "secret"
    config.last_request_succeeded.should eq false
  end
end
