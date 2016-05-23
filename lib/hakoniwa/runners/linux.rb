module Hakoniwa::Runners
  # see http://d.hatena.ne.jp/hiboma/20120518/1337337393

  class Linux
    UNSHARE = 272
    CLONE_NEWNS = 0x00020000

    def self.run(base, init_command)
      fork {
        unshare(CLONE_NEWNS)
        system "readlink /proc/$$/ns/mnt"

        base.filesystem.mount_all!

        Dir.chroot base.filesystem.chroot
        Dir.chdir "/"
        exec init_command
      }

      puts "New container: is OK?"
      system "readlink /proc/$$/ns/mnt"
      loop {} # to be in front
    end

    def self.unshare(flag)
      Kernel.syscall(UNSHARE, flag)
    end
  end
end
