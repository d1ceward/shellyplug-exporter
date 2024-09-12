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
    def initialize : Nil
      parser = option_parser
      parser.parse

      # If run_server flag is set, start the exporter server; otherwise, display help.
      @run_server ? server_start : display_help(parser, 1)
    end

    # Starts the server process.
    private def server_start : Nil
      Process.on_terminate do |reason|
        next unless reason.aborted? || reason.interrupted? || reason.session_ended?

        STDOUT.puts("terminating gracefully...")
        exit(0)
      end

      ShellyplugExporter::Server.new(config).run
    end

    # Print the version number to the standard output and exits the program.
    private def display_version : Nil
      STDOUT.puts "version #{ShellyplugExporter::VERSION}"
      exit
    end

    # Print the help message to the standard output for the CLI.
    private def display_help(parser : OptionParser, exit_code : Int32 = 0) : Nil
      STDOUT.puts(parser)
      exit(exit_code)
    end

    # This method is used to handle missing options in the command line interface.
    private def missing_option(parser : OptionParser, flag : String) : Nil
      STDERR.puts("ERROR: #{flag} is missing something.")
      STDERR.puts(parser)
      exit(1)
    end

    # This method is used to handle invalid options in the command line arguments.
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
