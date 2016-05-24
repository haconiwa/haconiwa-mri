require 'haconiwa'
require 'pathname'
haconiwa = Haconiwa::Base.define do |config|
  config.name = "chroot001" # to be hostname

  root = Pathname.new("/var/haconiwa/root")
  config.add_mount_point "/var/haconiwa/rootfs", to: root, readonly: true
  config.add_mount_point "/lib64", to: root.join("lib64"), readonly: true
  config.add_mount_point "/usr/bin", to: root.join("usr/bin"), readonly: true
  config.add_mount_point "/var/haconiwa/user_homes/haconiwa-test001/home/haconiwa", to: root.join("home/haconiwa")
  config.add_mount_point "proc", to: root.join("proc"), fs: "proc"
  config.chroot_to root

  # config.namespace.unshare "mount"
end

haconiwa.start("/bin/bash")
