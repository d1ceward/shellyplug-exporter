module ShellyplugExporter
  # CLI class handles command line interface interactions for the exporter.
  #
  # ```
  # ShellyplugExporter::CLI.new
  # ```
  class CLI
    # Configuration settings for the exporter.
    property config : Config = Config.new

    # Whether to run the exporter server.
    property? run_server : Bool = false

    # Initialize the CLI.
    def initialize
      parser = option_parser
      parser.parse

      # If run_server flag is set, start the exporter server; otherwise, display help.
      @run_server ? ShellyplugExporter::Server.new(config).run : display_help(parser, 1)
    end

    private def display_version
      STDOUT.puts "version #{ShellyplugExporter::VERSION}"
      exit
    end

    private def display_help(parser : OptionParser, exit_code : Int32 = 0)
      STDOUT.puts(parser)
      exit(exit_code)
    end

    private def missing_option(parser : OptionParser, flag : String)
      STDERR.puts("ERROR: #{flag} is missing something.")
      STDERR.puts("")
      STDERR.puts(parser)
      exit(1)
    end

    private def invalid_option(parser : OptionParser, flag : String)
      STDERR.puts("ERROR: #{flag} is not a valid option.")
      STDERR.puts(parser)
      exit(1)
    end

    private def option_parser
      OptionParser.new do |parser|
        parser.banner = "Prometheus Exporter for Shelly plugs\nUsage: shellyplug-exporter [subcommand]"

        parser.on("run", "Run exporter server") do
          @run_server = true

          parser.on("-p PORT", "--port=PORT", "Specifies exporter server port") do |port|
            config.exporter_port = port.to_i
          end

          parser.on("--plug-host=HOST", "Specifies plug http host") { |host| config.plug_host = host }
          parser.on("--plug-port=PORT", "Specifies plug http port") { |port|  config.plug_port = port.to_i }

          parser.on("--plug-auth-username=USERNAME", "Specifies plug http auth username") do |username|
            config.plug_auth_username = username
          end

          parser.on("--plug-auth-password=PASSWORD", "Specifies plug http auth password") do |password|
            config.plug_auth_password = password
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
