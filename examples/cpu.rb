require 'haconiwa'
require 'pathname'
haconiwa = Haconiwa::Base.define do |config|
  config.name = "cpu-quota001" # to be hostname

  root = Pathname.new("/var/haconiwa/root")
  config.add_mount_point "/var/haconiwa/rootfs", to: root, readonly: true
  config.add_mount_point "/lib64", to: root.join("lib64"), readonly: true
  config.add_mount_point "/usr/bin", to: root.join("usr/bin"), readonly: true
  config.add_mount_point "/usr/local/rbenv", to: root.join("usr/local/rbenv")
  config.add_mount_point "tmpfs", to: root.join("tmp"), fs: "tmpfs"
  config.mount_independent_procfs
  config.chroot_to root

  config.namespace.unshare "mount"
  config.namespace.unshare "ipc"
  config.namespace.unshare "uts"
  config.namespace.unshare "pid"

  config.cgroup["cpu.cfs_period_us"] = 100000
  config.cgroup["cpu.cfs_quota_us"]  =  30000
end

haconiwa.start("/bin/bash")
