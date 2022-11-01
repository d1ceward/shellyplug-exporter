module ShellyplugExporter
  class Cli
    property config : Config = Config.new
    property run_server : Bool = false

    def initialize
      parser = option_parser
      parser.parse

      if @run_server
        initialise_and_run_server
      else
        display_help(parser, 1)
      end
    end

    private def initialise_and_run_server
      return if ENV["CRYSTAL_SPEC_CONTEXT"]?

      ShellyplugExporter::Server.new(config).run
    end

    private def display_version
      puts "version #{ShellyplugExporter::VERSION}"
      exit
    end

    private def display_help(parser : OptionParser, exit_code : Int32 = 0)
      puts(parser)
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
          run_server = true

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
