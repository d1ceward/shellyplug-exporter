require "log"
require "option_parser"
require "kemal"
require "json"
require "http/client"

require "./version"
require "./shellyplug_exporter/config"
require "./shellyplug_exporter/server"
require "./shellyplug_exporter/plug"

# Disable CLI in testing context
if !ENV["CRYSTAL_SPEC_CONTEXT"]?
  # Initialize default config
  run_server = false
  config = ShellyplugExporter::Config.new

  # Intialize CLI parser
  option_parser = OptionParser.new do |parser|
    parser.banner = "Prometheus Exporter for Shelly plugs\nUsage: shellyplug_exporter [subcommand]"

    parser.on("run", "Run exporter server") do
      run_server = true
      parser.on("-p PORT", "--port=PORT", "Specifies exporter server port") do |port|
        config.exporter_port = port.to_i
      end

      parser.on("--plug-host=HOST", "Specifies plug http host") { |host| config.plug_host = host }
      parser.on("--plug-port=PORT", "Specifies plug http port") { |port| config.plug_port = port.to_i }

      parser.on("--plug-auth-username=USERNAME", "Specifies plug http auth username") do |username|
        config.plug_auth_username = username
      end

      parser.on("--plug-auth-password=PASSWORD", "Specifies plug http auth password") do |password|
        config.plug_auth_password = password
      end
    end

    parser.on("-v", "--version", "Show version") do
      puts "version #{ShellyplugExporter::VERSION}"
      exit
    end

    parser.on("-h", "--help", "Show help") do
      puts parser
      exit
    end

    parser.missing_option do |option_flag|
      STDERR.puts "ERROR: #{option_flag} is missing something."
      STDERR.puts ""
      STDERR.puts parser
      exit(1)
    end

    parser.invalid_option do |flag|
      STDERR.puts "ERROR: #{flag} is not a valid option."
      STDERR.puts parser
      exit(1)
    end
  end

  # Start server and prepare exporter http server
  option_parser.parse
  server = ShellyplugExporter::Server.new(config)

  # Run server is run command is supplied or print help and exit
  if run_server
    server.run
  else
    puts option_parser
    exit(1)
  end
end
