module Hakoniwa
  class Capabilities
    def initialize
      @blacklist = []
      @whitelist = []
    end

    def allow(*keys)
      if keys.first == :all
        @whitelist.clear
      end
    end

    def drop(*keys)
      @blacklist.concat(keys)
    end
  end
end
