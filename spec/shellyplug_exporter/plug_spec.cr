require "../spec_helper"

describe ShellyplugExporter::Plug do
  describe "#fetch_plug_data" do
    it "should return correct power value" do
      plug_data = ShellyplugExporter::Plug.new.fetch_plug_data

      plug_data["power"]?.try(&.as_f).should eq(73.24)
    end
  end
end
