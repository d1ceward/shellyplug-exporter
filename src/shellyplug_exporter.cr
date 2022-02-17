require "kemal"
require "json"
require "http/client"

require "./version"
require "./error"
require "./shellyplug_exporter/server"
require "./shellyplug_exporter/plug"

ShellyplugExporter::Server.run
