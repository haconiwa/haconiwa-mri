require 'hakoniwa'
require 'pathname'
hakoniwa = Hakoniwa::Base.define do |config|
  config.name = "chroot001" # to be hostname

  root = Pathname.new("/var/hakoniwa/root")
  config.add_mount_point "/var/hakoniwa/rootfs", to: root, readonly: true
  config.add_mount_point "/lib64", to: root.join("lib64"), readonly: true
  config.add_mount_point "/usr/bin", to: root.join("usr/bin"), readonly: true
  config.add_mount_point "/var/hakoniwa/user_homes/hakoniwa-test001/home/hakoniwa", to: root.join("home/hakoniwa")
  config.add_mount_point "proc", to: root.join("proc"), fs: "proc"
  config.chroot_to root

  # config.namespace.unshare "mount"
end

hakoniwa.start("/bin/bash")
