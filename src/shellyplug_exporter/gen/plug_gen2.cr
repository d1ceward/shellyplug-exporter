module ShellyplugExporter::Gen
  class PlugGen2
    def self.query_data(data : JSON::Any) : Hash(Symbol, Float64 | Int64)
      switch0 = data["switch:0"]?
      aenergy_total = switch0.try(&.["aenergy"]?).try(&.["total"]?).try(&.as_f?)
      {
        :power => switch0.try(&.["apower"]?).try(&.as_f?) || 0_f64,
        # Gen2 provides energy in Wh; convert to watt-minutes for consistency with Gen1
        :total => aenergy_total.try(&.*(60)).try(&.to_i64) || 0_i64,
        :temperature => switch0.try(&.["temperature"]?).try(&.["tC"]?).try(&.as_f?) || 0_f64,
        :uptime => data["sys"]?.try(&.["uptime"]?).try(&.as_i64?) || 0_i64
      }
    end

    def self.extract_name(config : JSON::Any) : String?
      config["sys"]?.try(&.["device"]?).try(&.["name"]?).try(&.as_s?)
    end
  end
end
