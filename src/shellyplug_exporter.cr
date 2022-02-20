require "kemal"
require "json"
require "http/client"
require "option_parser"

require "./version"
require "./error"
require "./shellyplug_exporter/server"
require "./shellyplug_exporter/plug"

OptionParser.parse do |parser|
  parser.banner = "Prometheus Exporter for Shelly plugs"

  parser.on("run", "Run exporter server") do
    ShellyplugExporter::Server.run
  end

  parser.on("-v", "--version", "Show version") do
    puts "version #{ShellyplugExporter::VERSION}"
    exit
  end

  parser.on "-h", "--help", "Show help" do
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
