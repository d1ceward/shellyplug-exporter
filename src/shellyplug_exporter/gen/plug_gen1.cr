module ShellyplugExporter::Gen
  class PlugGen1
    def self.query_data(data : JSON::Any) : Hash(Symbol, Float64 | Int64)
      meter = data["meters"]?.try(&.[0]?)
      Helper::JsonHelper.compact({
        power: Helper::JsonHelper.as_f?(meter.try(&.["power"]?)),
        overpower: Helper::JsonHelper.as_f?(meter.try(&.["overpower"]?)),
        total: meter.try(&.["total"]?).try(&.as_i64?),
        temperature: Helper::JsonHelper.as_f?(data["temperature"]?),
        overtemperature: data["overtemperature"]?.try(&.as_bool?).try { |hot| hot ? 1_i64 : 0_i64 },
        uptime: data["uptime"]?.try(&.as_i64?),
      })
    end

    def self.extract_name(config : JSON::Any) : String?
      config["name"]?.try(&.as_s?)
    end
  end
end
