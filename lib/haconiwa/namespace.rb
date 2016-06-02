module Haconiwa
  class Namespace
    UNSHARE = 272
    SETNS   = 308

    # from linux/sched.h

    CLONE_FS        = 0x00000200
    CLONE_FILES     = 0x00000400
    CLONE_NEWNS     = 0x00020000
    CLONE_SYSVSEM   = 0x00040000
    CLONE_NEWCGROUP = 0x02000000
    CLONE_NEWUTS    = 0x04000000
    CLONE_NEWIPC    = 0x08000000
    CLONE_NEWUSER   = 0x10000000
    CLONE_NEWPID    = 0x20000000
    CLONE_NEWNET    = 0x40000000

    NS_MAPPINGS = {
      "cgroup" => CLONE_NEWCGROUP,
      "ipc"    => CLONE_NEWIPC,
      "net"    => CLONE_NEWNET,
      "mount"  => CLONE_NEWNS,
      "pid"    => CLONE_NEWPID,
      "user"   => CLONE_NEWUSER,
      "uts"    => CLONE_NEWUTS,
    }

    FLAG_TO_LINK = {
      CLONE_NEWCGROUP => "cgroup",
      CLONE_NEWIPC    => "ipc",
      CLONE_NEWNET    => "net",
      CLONE_NEWNS     => "mnt",
      CLONE_NEWPID    => "pid",
      CLONE_NEWUSER   => "user",
      CLONE_NEWUTS    => "uts",
    }

    def initialize
      @use_ns = []
      @netns_name = nil
    end

    def unshare(ns)
      flag = case ns
             when String, Symbol
               NS_MAPPINGS[ns.to_s]
             when Integer
               ns
             end
      if flag == CLONE_NEWPID
        @use_pid_ns = true
      else
        @use_ns << flag
      end
    end
    attr_reader :use_pid_ns

    def use_netns(name)
      @netns_name = name
    end

    def apply!
      flag = to_ns_flag
      STDERR.puts "unshare(2) flag: 0x%s" % flag.to_s(16)
      Kernel.syscall(UNSHARE, flag)
    end

    def enter(pid: nil)
      fds = use_ns_all.map do |flag|
        nslink = File.open("/proc/#{pid}/ns/#{FLAG_TO_LINK[flag]}", 'r')
        [flag, fd]
      end
      fds.each do |(flag, fd)|
        Kernel.syscall(SETNS, fd.fileno, flag)
        fd.close
      end
    end

    private

    def use_ns_all
      @use_ns + (@use_pid_ns ? [CLONE_NEWPID] : [])
    end

    def to_ns_flag
      @use_ns.inject(0x00000000) { |dst, flag|
        dst |= flag
      }
    end
  end
end
