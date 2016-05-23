module Hakoniwa
  class Filesystem
    def initialize
      @mount_points = []
    end
    attr_accessor :chroot, :mount_points

    def mount_all!
      Dir.chdir "/"
      system "mount --make-private /"

      mount_points.each do |mount|
        mount.apply!
      end
    end
  end
end
