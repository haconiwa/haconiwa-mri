module Haconiwa
  class Filesystem
    def initialize
      @mount_points = []
      @mount_procfs = false
    end
    attr_accessor :chroot, :mount_points,
                  :mount_procfs

    def mount_all!
      Dir.chdir "/"
      unless mount_points.empty?
        system "mount --make-private /"

        mount_points.each do |mount|
          mount.apply!
        end
      end
    end
  end
end
