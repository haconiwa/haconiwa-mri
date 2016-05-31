require 'haconiwa/small_cgroup'

module Haconiwa
  class CGroup
    def initialize
      @groups = {}
    end
    attr_reader :groups

    def [](key)
      @groups[key]
    end

    def []=(key, value)
      @groups[key] = value
    end

    def to_dirs
      groups.keys.map{|k| k.split('.').first }.uniq
    end

    def register_all!(to: nil)
      cg = SmallCgroup.new(name: to)
      groups.each do |k, v|
        cg.register k, v
      end
    end
  end
end
