module ShellyplugExporter::Gen
  class PlugGen2
    def self.query_data(data : JSON::Any) : Hash(Symbol, Float64 | Int64)
      switch0 = data["switch:0"]?
      aenergy = switch0.try(&.["aenergy"]?)
      aenergy_total = Helper::JsonHelper.as_f?(aenergy.try(&.["total"]?))
      # by_minute[0] is the energy of the last completed minute in mWh, and
      # mWh over one minute times 0.06 gives the average power in watts
      last_minute = Helper::JsonHelper.as_f?(aenergy.try(&.["by_minute"]?).try(&.[0]?))
      Helper::JsonHelper.compact({
        power: Helper::JsonHelper.as_f?(switch0.try(&.["apower"]?)),
        power_avg_1m: last_minute.try { |milliwatt_hours| (milliwatt_hours * 0.06).round(3) },
        # Gen2 provides energy in Wh; convert to watt-minutes for consistency with
        # Gen1, rounding off the float noise the multiplication adds to the mWh
        # resolution the plug reports
        total: aenergy_total.try { |watt_hours| (watt_hours * 60).round(3) },
        temperature: Helper::JsonHelper.as_f?(switch0.try(&.["temperature"]?).try(&.["tC"]?)),
        uptime: data["sys"]?.try(&.["uptime"]?).try(&.as_i64?),
      })
    end

    def self.extract_name(config : JSON::Any) : String?
      config["sys"]?.try(&.["device"]?).try(&.["name"]?).try(&.as_s?)
    end
  end
end
