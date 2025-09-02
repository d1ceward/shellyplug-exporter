module CLIHelper
  def self.run_cli(*args)
    output = IO::Memory.new
    cmd = ["crystal", "run", "./src/shellyplug_exporter_run.cr", "--"] + args.to_a
    status = Process.run(cmd[0], cmd[1..], output: output, error: output)

    { status, output.to_s }
  end
end
