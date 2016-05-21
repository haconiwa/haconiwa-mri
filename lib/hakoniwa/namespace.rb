module Hakoniwa
  class Namespace
    def initialize
      @use_ns = []
      @netns_name = nil
    end

    def unshare(ns_type)
      @use_ns << ns_type
    end

    def use_netns(name)
      @netns_name = name
    end
  end
end
