module ShellyplugExporter
  # HTTP server formatting and returning metrics
  class Server
    def initialize(@config : Config) : Nil
      @plug_instance = Plug.new(@config)
    end

    # Start a server for prometheus to retrieve metrics
    def run : Nil
      server = HTTP::Server.new do |context|
        # Setting the content type to text/plain for prometheus
        context.response.content_type = "text/plain"

        # Match the request's path to different routes and call corresponding handlers
        case context.request.path
        when "/metrics" then metrics_handler(context)
        when "/health" then health_handler(context)
        else
          # Return a 404 response for unknown routes
          context.response.status_code = 404
          context.response.print("Not found")
        end
      end

      Log.info { "Metrics server listening on http://0.0.0.0:#{@config.exporter_port}." }
      server.bind_tcp("0.0.0.0", @config.exporter_port)
      server.listen
    end

    private def build_prometheus_response(data : Hash(Symbol, Float64 | Int64)) : String
      String.build do |io|
        # shellyplug_power metric
        io << "# HELP shellyplug_power Current power drawn in watts\n"
        io << "# TYPE shellyplug_power gauge\n"
        io << "shellyplug_power #{data[:power]}\n"

        # shellyplug_overpower metric
        io << "# HELP shellyplug_overpower Overpower drawn in watts\n"
        io << "# TYPE shellyplug_overpower gauge\n"
        io << "shellyplug_overpower #{data[:overpower]}\n"

        # shellyplug_total_power metric
        io << "# HELP shellyplug_total_power Total power consumed in watt-minute\n"
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

    private def metrics_handler(context : HTTP::Server::Context) : Nil
      context.response.status_code = 200
      context.response.print(build_prometheus_response(@plug_instance.query_data))
    end

    private def health_handler(context : HTTP::Server::Context) : Nil
      if @config.last_request_succeded.nil? || @config.last_request_succeded
        context.response.status_code = 200
        context.response.print("OK: Everything is fine")
      else
        context.response.status_code = 503
        context.response.print("ERROR: The last plug request did not work")
      end
    end
  end
end
