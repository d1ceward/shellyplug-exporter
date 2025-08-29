module ShellyplugExporter
  # CLI class handles command line interface interactions for the exporter.
  class CLI
    property config_path : String? = nil
    property exporter_port : Int32? = nil
    property? run_server : Bool = false

    def initialize : Nil
      parser = build_option_parser
      parser.parse
      run_server? ? start_server : show_help(parser, 1)
    end

    private def start_server : Nil
      setup_signal_handlers

      config = Config.load(config_path)
      plugs = config.plugs.map { |plug_config| Plug.new(plug_config) }
      port = exporter_port || config.exporter_port

      # Write only exporter port to a known file for healthcheck
      begin
        File.write("/run/shellyplug-exporter.info", "EXPORTER_PORT=#{port}\n")
      rescue ex
        STDERR.puts "Warning: Could not write /run/shellyplug-exporter.info: #{ex.message}"
      end

      Server.new(plugs, port).run
    end

    private def setup_signal_handlers : Nil
      Process.on_terminate do |reason|
        if reason.aborted? || reason.interrupted? || reason.session_ended?
          STDOUT.puts("terminating gracefully...")
          exit(0)
        end
      end
    end

    private def show_version : Nil
      STDOUT.puts "version #{ShellyplugExporter::VERSION}"
      exit
    end

    private def show_help(parser : OptionParser, exit_code : Int32 = 0) : Nil
      STDOUT.puts(parser)
      exit(exit_code)
    end

    private def handle_missing_option(parser : OptionParser, flag : String) : Nil
      STDERR.puts("ERROR: #{flag} is missing something.")
      STDERR.puts(parser)
      exit(1)
    end

    private def handle_invalid_option(parser : OptionParser, flag : String) : Nil
      STDERR.puts("ERROR: #{flag} is not a valid option.")
      STDERR.puts(parser)
      exit(1)
    end

    private def build_option_parser : OptionParser
      OptionParser.new do |parser|
        parser.banner = "Prometheus Exporter for Shelly plugs\nUsage: shellyplug-exporter [subcommand]"
        parser.on("run", "Run exporter server") do
          @run_server = true

          parser.on("-c FILE", "--config=FILE", "YAML config file for multiple plugs") do |file|
            @config_path = file
          end

          parser.on("-p PORT", "--port=PORT", "Exporter server port (overrides config)") do |port|
            @exporter_port = port.to_i
          end
        end

        parser.on("-v", "--version", "Show version") { show_version }
        parser.on("-h", "--help", "Show help") { show_help(parser) }
        parser.missing_option { |flag| handle_missing_option(parser, flag) }
        parser.invalid_option { |flag| handle_invalid_option(parser, flag) }
      end
    end
  end
end
