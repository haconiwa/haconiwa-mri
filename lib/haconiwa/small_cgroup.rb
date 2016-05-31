require 'pathname'
require 'fileutils'

module Haconiwa
  class SmallCgroup
    class << self
      attr_accessor :fs_root

      def register_at_exit(pid, name, dirs)
        at_exit do
          dirs.each do |dir|
            begin
              cleanup = fs_root.join(dir, name)
              FileUtils.rmdir(cleanup)
            rescue
              STDERR.puts "Failed to remove: #{cleanup}"
            end
          end
        end
      end
    end
    self.fs_root = Pathname.new("/sys/fs/cgroup")

    def initialize(name: "haconiwa-#{$$}", pid: $$)
      @name = name
      @pid  = pid
      @active_dirs = []
    end
    attr_reader :name, :pid

    def activate(dir)
      dirroot = root_of(dir)
      FileUtils.mkdir_p dirroot
      append_write dirroot.join("tasks"), self.pid
      @active_dirs << dir
    end

    def activated?(dir)
      @active_dirs.include? dir
    end

    def register(key, value)
      dir = key.split('.').first
      unless activated?(dir)
        activate(dir)
      end

      overwrite root_of(dir).join(key), value
    end

    private

    def root_of(dir)
      SmallCgroup.fs_root.join(dir, self.name)
    end

    def append_write(file, value)
      File.open(file, 'a') {|f| f.puts value }
    end

    def overwrite(file, value)
      File.open(file, 'w') {|f| f.puts value }
    end
  end
end
