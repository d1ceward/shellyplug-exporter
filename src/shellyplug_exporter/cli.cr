module ShellyplugExporter
  # CLI class handles command line interface interactions for the exporter.
  class CLI
    property config_path : String? = nil
    property? run_server : Bool = false

    def initialize : Nil
      # Catch termination signals for graceful shutdown
      Process.on_terminate do |reason|
        next unless reason.aborted? || reason.interrupted? || reason.session_ended?

        STDOUT.puts("terminating gracefully...")
        exit(0)
      end

      parser = option_parser
      parser.parse

      # If run_server flag is set, start the exporter server; otherwise, display help.
      @run_server ? server_start : display_help(parser, 1)
    end

    private def server_start : Nil
      config = Config.load(config_path)
      plugs = config.plugs.map { |plug_config| Plug.new(plug_config) }
      port = exporter_port || config.exporter_port

      Server.new(plugs, port).run
    end

    private def display_version : Nil
      STDOUT.puts "version #{ShellyplugExporter::VERSION}"
      exit
    end

    private def display_help(parser : OptionParser, exit_code : Int32 = 0) : Nil
      STDOUT.puts(parser)
      exit(exit_code)
    end

    private def missing_option(parser : OptionParser, flag : String) : Nil
      STDERR.puts("ERROR: #{flag} is missing something.")
      STDERR.puts(parser)
      exit(1)
    end

    private def invalid_option(parser : OptionParser, flag : String) : Nil
      STDERR.puts("ERROR: #{flag} is not a valid option.")
      STDERR.puts(parser)
      exit(1)
    end

    private def option_parser : OptionParser
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

        parser.on("-v", "--version", "Show version") { display_version }
        parser.on("-h", "--help", "Show help") { display_help(parser) }
        parser.missing_option { |flag| missing_option(parser, flag) }
        parser.invalid_option { |flag| invalid_option(parser, flag) }
      end
    end
  end
end
