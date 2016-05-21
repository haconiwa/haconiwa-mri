module Hakoniwa
  class Filesystem
    def initialize
      @mount_points = []
    end
    attr_accessor :chroot, :mount_points
  end
end
