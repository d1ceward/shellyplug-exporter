require "log"
require "option_parser"
require "kemal"
require "json"
require "http/client"

require "./version"
require "./shellyplug_exporter/cli"
require "./shellyplug_exporter/config"
require "./shellyplug_exporter/server"
require "./shellyplug_exporter/plug"

ShellyplugExporter::Cli.new
