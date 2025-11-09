module ShellyplugExporter::Gen
  class PlugGen1
    def self.query_data(data)
      meter = data["meters"]?.try(&.[0])
      {
        :power => meter.try(&.["power"]?).try(&.as_f?) || 0_f64,
        :overpower => meter.try(&.["overpower"]?).try(&.as_f?) || 0_f64,
        :total => meter.try(&.["total"]?).try(&.as_i64?) || 0_i64,
        :temperature => data["temperature"]?.try(&.as_f?) || 0_f64,
        :overtemperature => data["overtemperature"]?.try(&.as_bool?) ? 1_i64 : 0_i64,
        :uptime => data["uptime"]?.try(&.as_i64?) || 0_i64
      }
    end

    def self.extract_name(config)
      config["name"]?.try(&.as_s?)
    end
  end
end
