require "haconiwa/filesystem"
require "haconiwa/mount_point"
require "haconiwa/cgroup"
require "haconiwa/namespace"
require "haconiwa/capabilities"
require "haconiwa/runners"

module Haconiwa
  class Base
    attr_accessor :name,
                  :init_command,
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
      @name = "haconiwa-#{Time.now.to_i}"
    end

    # aliases
    def chroot_to(dest)
      self.filesystem.chroot = dest
    end

    def add_mount_point(point, options)
      self.namespace.unshare "mount"
      self.filesystem.mount_points << MountPoint.new(point, options)
    end

    def mount_independent_procfs
      self.namespace.unshare "mount"
      self.filesystem.mount_independent_procfs = true
    end

    def start(*init_command)
      Runners::Linux.run(self, init_command)
    end
    alias run start
  end

  def self.define(&b)
    Base.define(&b)
  end

  module Utils
    # $ ausyscall --dump | grep hostname
    # 170     sethostname

    def sethostname(name)
      Kernel.syscall(170, name, name.length)
    end
  end

  Base.extend Utils
end
