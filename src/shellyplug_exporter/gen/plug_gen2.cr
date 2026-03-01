module ShellyplugExporter::Gen
  class PlugGen2
    def self.query_data(data)
      switch0 = data["switch:0"]?
      {
        :power => switch0.try(&.["apower"]?).try(&.as_f?) || 0_f64,
        :total => switch0.try(&.["aenergy"]?).try(&.["total"]?).try(&.as_f?).try(&.*(60)).try(&.to_i64) || 0_i64, # Gen2 provides energy in Wh; convert to watt-minutes for consistency with Gen1
        :temperature => switch0.try(&.["temperature"]?).try(&.["tC"]?).try(&.as_f?) || 0_f64,
        :uptime => data["sys"]?.try(&.["uptime"]?).try(&.as_i64?) || 0_i64
      }
    end

    def self.extract_name(config)
      config["sys"]?.try(&.["device"]?).try(&.["name"]?).try(&.as_s?)
    end
  end
end
