class TestBase < Test::Unit::TestCase
  def test_define
    hakoniwa = Hakoniwa::Base.define do |config|
      config.name = "new-hakoniwa001"

      config.cgroup["cpu.shares"] = 2048
      config.cgroup["memory.limit_in_bytes"] = "256M"
      config.cgroup["pid.max"] = 1024

      config.chroot_to "/var/your_rootfs"
      config.add_mount_point "/var/another/root/etc", to: "/etc", readonly: true
      config.add_mount_point "/var/another/root/home", to: "/home"
      config.add_mount_point "proc", to: "/proc", fs: "proc"

      config.namespace.unshare "ipc"
      config.namespace.unshare "mount"
      config.namespace.unshare "pid"
      config.namespace.use_netns "foobar"

      config.capabilities.allow :all
      config.capabilities.drop "CAP_SYS_TIME"
    end

    assert { hakoniwa.name == "new-hakoniwa001" }
  end
end
