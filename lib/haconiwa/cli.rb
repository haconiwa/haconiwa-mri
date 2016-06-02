module Haconiwa
  module Cli
    def self.run(args)
      base, init = get_script_and_eval(args)
      base.run(*init)
    end

    def self.attach(args)
      require 'optparse'
      opt = OptionParser.new
      pid = nil
      name = nil

      opt.program_name = "haconiwa attach"
      opt.on('-t', '--target PID', "Container's PID to attatch. If not set, use pid file of definition") {|v| pid = v }
      opt.on('-n', '--name CONTAINER_NAME', "Container's name. Set if the name is dynamically defined") {|v| name = v }
      args = opt.parse(args)

      base, exe = get_script_and_eval(args)
      base.pid = pid if pid
      base.name = name if name
      base.attach(*exe)
    end

    private

    def self.get_script_and_eval(args)
      require 'pathname'
      script = File.read(args[0])
      exe    = args[1..-1]
      if exe.first == "--"
        exe.shift
      end

      return [eval(script), exe]
    end
  end
end
