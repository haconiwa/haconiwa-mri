module Haconiwa
  class CGroup
    def initialize
      @groups = {}
    end
    attr_reader :groups

    def [](key)
      @groups[key]
    end

    def []=(key, value)
      @groups[key] = value
    end
  end
end
