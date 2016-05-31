require 'tempfile'
require 'fileutils'

module Haconiwa::Runners
  # see http://d.hatena.ne.jp/hiboma/20120518/1337337393

  class Linux
    def self.run(base, init_command)
      container = fork {
        base.namespace.apply!

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
          exec "unshare", "--pid", "--", wrapper.path, init_command
        else
          exec wrapper.path, init_command
        end
      }

      puts "New container: PID = #{container}"

      Process.waitpid container
      puts "Successfully exit container."
    end
  end
end
