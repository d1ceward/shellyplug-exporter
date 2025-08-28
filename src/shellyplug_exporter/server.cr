module ShellyplugExporter
  # HTTP server for Prometheus metrics for one or more Shelly plugs.
  class Server
    @server : HTTP::Server
    @plugs : Array(Plug)
    @exporter_port : Int32

    def initialize(plugs : Array(Plug), exporter_port : Int32)
      @plugs = plugs
      @exporter_port = exporter_port
      @server = HTTP::Server.new do |context|
        context.response.content_type = "text/plain"
        route(context)
      end

      @server.bind_tcp("0.0.0.0", exporter_port)
    end

    def run : Nil
      Log.info { "Metrics server listening on http://0.0.0.0:#{@exporter_port}." }
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

    private def build_prometheus_response(plug : Plug, data : Hash(Symbol, Float64 | Int64)) : String
      plug_name = plug.name.presence || plug.config.host.presence || "unknown"
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

    private def build_prometheus_response_all : String
      @plugs.map do |plug|
        data = plug.query_data
        build_prometheus_response(plug, data)
      end.join("\n")
    end

    private def metrics_handler(context : HTTP::Server::Context) : Nil
      context.response.status_code = 200
      context.response.print(build_prometheus_response_all)
    end

    private def health_handler(context : HTTP::Server::Context) : Nil
      # Check if any plug has a failed last request
      failed_request = @plugs.any? do |plug|
        plug.config.last_request_succeeded == false
      end

      if failed_request
        context.response.status_code = 503
        context.response.print("ERROR: One or more plugs are not responding, logs may contain more details.")
      else
        context.response.status_code = 200
        context.response.print("OK: Everything is fine")
      end
    end

    private def not_found_handler(context : HTTP::Server::Context) : Nil
      context.response.status_code = 404
      context.response.print("Not found")
    end
  end
end
