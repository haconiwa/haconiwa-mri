module Haconiwa
  class MountPoint
    def initialize(point, options)
      @src = point
      @dest = options.delete(:to)
      @readonly = options.delete(:readonly)
      @fs = options.delete(:fs)
      @options = options
    end

    def to_command
      if @fs
        "mount -t #{@fs} #{@src} #{@dest}"
      else
        "mount --bind #{@src} #{@dest}"
      end
    end

    def apply!
      STDERR.puts to_command
      system to_command
      if @readonly
        STDERR.puts "mount --bind -o remount,ro #{@dest}"
        system "mount --bind -o remount,ro #{@dest}"
      end
    end
  end
end
