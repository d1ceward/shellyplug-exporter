require "log"
require "option_parser"
require "kemal"
require "json"
require "http/client"

require "./version"
require "./shellyplug_exporter/config"
require "./shellyplug_exporter/server"
require "./shellyplug_exporter/plug"

if !ENV["CRYSTAL_SPEC_CONTEXT"]?
  run_server = false
  port = nil
  option_parser = OptionParser.new do |parser|
    parser.banner = "Prometheus Exporter for Shelly plugs\nUsage: shellyplug_exporter [subcommand]"

    parser.on("run", "Run exporter server") do
      run_server = true
      parser.on("-p PORT", "--port=PORT", "Specifies exporter server port") do |given_port|
        port = given_port.to_i
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

  option_parser.parse

  config = ShellyplugExporter::Config.new(port)
  server = ShellyplugExporter::Server.new(config)

  if run_server
    server.run
  else
    puts option_parser
    exit(1)
  end
end
