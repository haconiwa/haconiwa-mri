require 'tempfile'
require 'fileutils'
require 'bundler'

module Haconiwa::Runners
  # see http://d.hatena.ne.jp/hiboma/20120518/1337337393

  class Linux
    def self.run(base, init_command)
      container = fork {
        base.namespace.apply!
        base.cgroup.register_all!(to: base.name)

        base.filesystem.mount_all!

        Dir.chroot base.filesystem.chroot
        Dir.chdir "/"

        wrapper = Tempfile.open("haconiwa-wrapper-#{$$}-#{Time.now.to_i}.sh")

        wrapper.puts "#!/bin/bash"
        wrapper.puts "/bin/bash -c \""
        if base.filesystem.mount_independent_procfs
          wrapper.puts "mount -t proc proc /proc;"
        end
        wrapper.puts "exec $1;"
        wrapper.puts "\""
        wrapper.close
        FileUtils.chmod 0700, wrapper.path

        if base.namespace.use_pid_ns
          Bundler.with_clean_env {
            exec "unshare", "--pid", "--", wrapper.path, init_command
          }
        else
          Bundler.with_clean_env { exec wrapper.path, init_command }
        end
      }

      Haconiwa::SmallCgroup.register_at_exit(pid: container, name: base.name, dirs: base.cgroup.to_dirs)
      puts "New container: PID = #{container}"

      Process.waitpid container
      puts "Successfully exit container."
    end
  end
end
