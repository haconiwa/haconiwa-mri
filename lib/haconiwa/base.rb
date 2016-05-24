require "haconiwa/filesystem"
require "haconiwa/mount_point"
require "haconiwa/cgroup"
require "haconiwa/namespace"
require "haconiwa/capabilities"
require "haconiwa/runners"

module Haconiwa
  class Base
    attr_accessor :name,
                  :filesystem,
                  :cgroup,
                  :namespace,
                  :capabilities

    def self.define(&b)
      new.tap(&b)
    end

    def initialize
      @filesystem = Filesystem.new
      @cgroup = CGroup.new
      @namespace = Namespace.new
      @capabilities = Capabilities.new
    end

    # aliases
    def chroot_to(dest)
      self.filesystem.chroot = dest
    end

    def add_mount_point(point, options)
      self.filesystem.mount_points << MountPoint.new(point, options)
    end

    def start(init_command='/sbin/init')
      Runners::Linux.run(self, init_command)
    end
    alias run start
  end
end
