module ShellyplugExporter
  # HTTP server for Prometheus metrics for one or more Shelly plugs.
  class Server
    alias PlugData = Hash(Symbol, Float64 | Int64)
    alias PlugSample = Tuple(Plug, PlugData)

    # Metric families exposed on /metrics, in output order.
    METRICS = {
      up: {help: "Last scrape of the plug succeeded (1) or failed (0)", type: "gauge"},
      power: {help: "Current power drawn in watts", type: "gauge"},
      overpower: {help: "Overpower drawn in watts", type: "gauge"},
      total: {help: "Total power consumed in watt-minute", type: "counter"},
      temperature: {help: "Plug temperature in celsius", type: "gauge"},
      overtemperature: {help: "Plug overtemperature status (0 or 1)", type: "gauge"},
      uptime: {help: "Plug uptime in seconds", type: "gauge"},
    }

    @server : HTTP::Server
    @plugs : Array(Plug)
    @exporter_port : Int32

    def initialize(plugs : Array(Plug), exporter_port : Int32) : Nil
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

    # Scrapes every plug concurrently, so a slow or unreachable plug does not
    # delay the others and push the whole scrape past Prometheus' timeout.
    private def collect_samples : Array(PlugSample)
      results = Array(PlugSample?).new(@plugs.size, nil)
      wait_group = WaitGroup.new

      @plugs.each_with_index do |plug, index|
        wait_group.spawn { results[index] = {plug, scrape(plug)} }
      end

      wait_group.wait
      results.compact
    end

    private def scrape(plug : Plug) : PlugData
      data = plug.query_data
      data[:up] = plug.config.last_request_succeeded ? 1_i64 : 0_i64
      data
    rescue ex
      Log.error { "Failed to scrape #{plug.config.host}: #{ex.message}" }
      plug.config.last_request_succeeded = false

      {:up => 0_i64} of Symbol => Float64 | Int64
    end

    # Prometheus rejects a metric family whose HELP or TYPE line appears more
    # than once, so every sample of a family is grouped under a single header.
    private def build_prometheus_response_all : String
      samples = collect_samples

      String.build do |io|
        METRICS.each do |key, meta|
          matching = samples.select { |(_, data)| data.has_key?(key) }
          next if matching.empty?

          io << "# HELP shellyplug_" << key << ' ' << meta[:help] << '\n'
          io << "# TYPE shellyplug_" << key << ' ' << meta[:type] << '\n'
          matching.each do |(plug, data)|
            io << "shellyplug_" << key << "{name=\"" << plug_label(plug) << "\"} " << data[key] << '\n'
          end
        end
      end
    end

    private def plug_label(plug : Plug) : String
      escape_label_value(plug.name.presence || plug.config.host.presence || "unknown")
    end

    private def escape_label_value(value : String) : String
      value.gsub({'\\' => "\\\\", '"' => "\\\"", '\n' => "\\n"})
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
