module Haconiwa
  module Cli
    def self.run(args)
      base, init = get_script_and_eval(args)
      base.run(*init)
    end

    def self.attach(args)
      base, exe = get_script_and_eval(args)
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
