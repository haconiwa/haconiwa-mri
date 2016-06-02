require 'tempfile'
require 'fileutils'
require 'shellwords'
require 'bundler'

module Haconiwa::Runners
  # see http://d.hatena.ne.jp/hiboma/20120518/1337337393

  class Linux
    def self.run(base, init_command=[])
      container = fork {
        if init_command.empty?
          init_command = Array(base.init_command)
        end

        base.namespace.apply!
        base.cgroup.register_all!(to: base.name)

        base.filesystem.mount_all!

        Dir.chroot base.filesystem.chroot
        Dir.chdir "/"

        wrapper = Tempfile.open("haconiwa-wrapper-#{$$}-#{Time.now.to_i}.sh")

        wrapper.puts "#!/bin/bash"
        wrapper.puts "/bin/bash -c '"
        if base.filesystem.mount_independent_procfs
          wrapper.puts "mount -t proc proc /proc;"
        end
        wrapper.puts "exec $@;"
        wrapper.puts "' -- \"$@\""
        wrapper.close
        FileUtils.chmod 0700, wrapper.path

        Haconiwa::Base.sethostname(base.name)

        base.capabilities.apply!

        if base.namespace.use_pid_ns
          Bundler.with_clean_env {
            exec "unshare", "--pid", "--", wrapper.path, *init_command
          }
        else
          Bundler.with_clean_env { exec wrapper.path, *init_command }
        end
      }

      sleep 0.1 # The magic
      Haconiwa::SmallCgroup.register_at_exit(pid: container, name: base.name, dirs: base.cgroup.to_dirs)
      real_container_pid = if base.namespace.use_pid_ns
                             find_by_ppid(container)
                           else
                             container
                           end
      File.open(base.container_pid_file, "w") {|pid| pid.write real_container_pid }
      puts "New container: PID = #{real_container_pid}"

      res = Process.waitpid2 container
      if res[1].success?
        puts "Successfully exit container."
      else
        puts "Container exited with status code <#{res[1].to_i}>."
      end

      at_exit { FileUtils.rm_f base.container_pid_file }
    end

    def self.attach(base, run_command=[])
      if run_command.empty?
        run_command << "/bin/bash"
      end

      wrapper = Tempfile.open("haconiwa-attacher-#{$$}-#{Time.now.to_i}.sh")

      wrapper.puts "#!/bin/bash"
      wrapper.puts "chroot #{base.filesystem.chroot} bash -c '"
      wrapper.puts "cd / ;"
      wrapper.puts Shellwords.shelljoin(["exec", *run_command]).gsub(/'/, %<'"'"'>)
      wrapper.puts "'"
      wrapper.close
      FileUtils.chmod 0700, wrapper.path

      runner = fork {
        # base.cgroup.enter(name: base.name)
        base.namespace.enter(
          pid: File.read(base.container_pid_file).to_i,
          wrapper_path: wrapper.path
        )
      }

      puts "Attached to contanier: Runner PID = #{runner}"

      res = Process.waitpid2 runner
      if res[1].success?
        puts "Successfully exit."
      else
        puts "Attached process exited with status code <#{res[1].to_i}>."
      end
    end

    private
    def self.find_by_ppid(ppid)
      s = Dir.glob('/proc/*/stat')
             .find {|stat|
               next unless stat =~ /\d/
               File.read(stat).split[3].to_i == ppid
             }
      if s
        s.scan(/\d+/).first.to_i
      else
        raise("Process that has ppid #{ppid} not found. Somthing is wrong.")
      end
    end
  end
end
