module Hakoniwa
  class MountPoint
    def initialize(point, options)
      @src = point
      @dest = options.delete(:to)
      @readonly = options.delete(:readonly)
      @options = options
    end

    def to_command
      "mount --bind #{@src} #{@dest}"
    end

    def apply!
      system to_command
      if @readonly
        system "mount -o remount,ro #{@dest}"
      end
    end
  end
end
