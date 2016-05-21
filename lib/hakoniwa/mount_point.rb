module Hakoniwa
  class MountPoint
    def initialize(point, options)
      @src = point
      @dest = options.delete(:to)
      @readonly = options.delete(:readonly)
      @options = options
    end
  end
end
