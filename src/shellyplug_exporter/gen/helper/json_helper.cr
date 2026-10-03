module ShellyplugExporter::Gen::Helper
  module JsonHelper
    # Shelly firmwares serialize whole numbers without a decimal point, which JSON::Any#as_f? rejects, so
    # accept integers as well.
    def self.as_f?(value : JSON::Any?) : Float64?
      return unless value

      value.as_f? || value.as_i64?.try(&.to_f)
    end

    # Drops the readings the plug did not report, so a failed or partial response yields no sample instead of
    # a misleading zero.
    def self.compact(readings : NamedTuple) : Hash(Symbol, Float64 | Int64)
      result = {} of Symbol => Float64 | Int64
      readings.each { |key, value| result[key] = value if value }
      result
    end
  end
end
