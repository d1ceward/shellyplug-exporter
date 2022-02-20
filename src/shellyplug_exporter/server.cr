module ShellyplugExporter
  class Server
    # Start the listening server for Prometheus
    def self.run : Nil
      # Server config
      Kemal.config.env = "production"
      Kemal.config.host_binding = "0.0.0.0"
      Kemal.config.port = 3000

      plug_instance = Plug.new

      # Route that return metrics data
      get "/" do
        plug_data = begin
                      plug_instance.fetch_plug_data
                    rescue ex : MissingHostname | InvalidCredentials
                      puts("No data, #{ex} !")
                      JSON.parse("{}")
                    end

        String.build do |io|
          io << "# HELP power Current power drawn in watts\n"
          io << "# TYPE power gauge\n"
          io << "power #{plug_data["power"]?.try(&.as_f?) || 0}\n"
          io << "# HELP total_power Total power consumed in Watt-minute\n"
          io << "# TYPE total_power gauge"
          io << "total_power #{plug_data["total"]?.try(&.as_i?) || 0}\n"
        end
      end

      # Start webserver
      Kemal.run
    end
  end
end
