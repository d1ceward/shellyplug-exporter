module ShellyplugExporter
  # HTTP server formatting and returning metrics
  class Server
    @server : HTTP::Server

    def initialize(@config : Config)
      @plug_instance = Plug.new(@config)

      @server = HTTP::Server.new do |context|
        context.response.content_type = "text/plain"
        route(context)
      end

      @server.bind_tcp("0.0.0.0", @config.exporter_port)
    end

    # Start a server for prometheus to retrieve metrics
    def run : Nil
      Log.info { "Metrics server listening on http://0.0.0.0:#{@config.exporter_port}." }
      @server.listen
    end

    def stop : Nil
      Log.info { "Stopping metrics server." }
      @server.close
    end

    private def route(context : HTTP::Server::Context) : Nil
      case context.request.path
      when "/metrics" then metrics_handler(context)
      when "/health"  then health_handler(context)
      else
        not_found_handler(context)
      end
    end

    private def build_prometheus_response(data : Hash(Symbol, Float64 | Int64)) : String
      plug_name = @plug_instance.name || "unknown"
      label = "{name=\"#{plug_name}\"}"

      String.build do |io|
        metrics = {
          power: { help: "Current power drawn in watts", type: "gauge" },
          overpower: { help: "Overpower drawn in watts", type: "gauge" },
          total: { help: "Total power consumed in watt-minute", type: "counter" },
          temperature: { help: "Plug temperature in celsius", type: "gauge" },
          uptime: { help: "Plug uptime in seconds", type: "gauge" },
        }

        metrics.each do |key, meta|
          io << "# HELP shellyplug_#{key} #{meta[:help]}\n"
          io << "# TYPE shellyplug_#{key} #{meta[:type]}\n"
          io << "shellyplug_#{key}#{label} #{data[key]}\n"
        end
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

    private def not_found_handler(context : HTTP::Server::Context) : Nil
      context.response.status_code = 404
      context.response.print("Not found")
    end
  end
end
