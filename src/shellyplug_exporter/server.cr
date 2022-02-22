module ShellyplugExporter
  # HTTP server formatting and returning metrics
  class Server
    def initialize(@config : Config)
      @plug_instance = Plug.new(@config)
    end

    # Start a server for prometheus to retrieve metrics
    def run
      initialize_server_config

      # The only needed route for prometheus
      get "/metrics" { build_prometheus_response(@plug_instance.query_data) }

      Kemal.run
    end

    private def initialize_server_config
      Kemal.config.env = "production"
      Kemal.config.host_binding = "0.0.0.0"
      Kemal.config.port = @config.exporter_port
    end

    private def build_prometheus_response(data : Hash(Symbol, Float64 | Int64)) : String
      String.build do |io|
        # shellyplug_power metric
        io << "# HELP shellyplug_power Current power drawn in watts\n"
        io << "# TYPE shellyplug_power gauge\n"
        io << "shellyplug_power #{data[:power]}\n"

        # shellyplug_overpower metric
        io << "# HELP shellyplug_overpower Overpower drawn in watts/minute\n"
        io << "# TYPE shellyplug_overpower gauge\n"
        io << "shellyplug_overpower #{data[:overpower]}\n"

        # shellyplug_total_power metric
        io << "# HELP shellyplug_total_power Total power consumed in watts/minute\n"
        io << "# TYPE shellyplug_total_power counter\n"
        io << "shellyplug_total_power #{data[:total]}\n"

        # shellyplug_temperature metric
        io << "# HELP shellyplug_temperature Plug temperature in celsius\n"
        io << "# TYPE shellyplug_temperature gauge\n"
        io << "shellyplug_temperature #{data[:temperature]}\n"

        # shellyplug_uptime metric
        io << "# HELP shellyplug_uptime Plug uptime in seconds\n"
        io << "# TYPE shellyplug_uptime gauge\n"
        io << "shellyplug_uptime #{data[:uptime]}\n"
      end
    end
  end
end
