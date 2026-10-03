require "../../../spec_helper"

alias JsonHelper = ShellyplugExporter::Gen::Helper::JsonHelper

describe JsonHelper do
  describe ".as_f?" do
    it "reads floats" do
      JsonHelper.as_f?(JSON.parse("12.5")).should eq(12.5)
    end

    it "reads whole numbers serialized without a decimal point" do
      JsonHelper.as_f?(JSON.parse("0")).should eq(0.0)
    end

    it "returns nil for missing or non-numeric values" do
      JsonHelper.as_f?(nil).should be_nil
      JsonHelper.as_f?(JSON.parse(%("on"))).should be_nil
    end
  end

  describe ".compact" do
    it "keeps reported readings, including zeros, and drops missing ones" do
      JsonHelper.compact({power: 0.0, total: nil, uptime: 5_i64})
                .should eq({:power => 0.0, :uptime => 5_i64})
    end
  end
end
