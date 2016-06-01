module Haconiwa
  module Cli
    def self.run(args)
      require 'pathname'
      script = File.read(args[0])
      init   = args[1]

      container = eval(script)
      container.run(init)
    end
  end
end
