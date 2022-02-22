module ShellyplugExporter
  class Server
    def initialize(@config : Config)
      @plug_instance = Plug.new(@config)
    end

    def run
      initialize_server_config

      # The only needed route for prometheus
      get "/metrics" { build_prometheus_response(@plug_instance.query_data) }

      Kemal.run
    end

    private def initialize_server_config
      Kemal.config.env = "production"
      Kemal.config.host_binding = "0.0.0.0"
      Kemal.config.port = @config.exporter_server_port
    end

    private def build_prometheus_response(data : Hash(Symbol, Float64 | Int64)) : String
      String.build do |io|
        # shellyplug_power metric
        io << "# HELP shellyplug_power Current power drawn in watts\n"
        io << "# TYPE shellyplug_power gauge\n"
        io << "shellyplug_power #{data[:power]}\n"

        # shellyplug_total_power metric
        io << "# HELP shellyplug_total_power Total power consumed in watts/minute\n"
        io << "# TYPE shellyplug_total_power gauge\n"
        io << "shellyplug_total_power #{data[:total]}\n"
      end
    end
  end
end
