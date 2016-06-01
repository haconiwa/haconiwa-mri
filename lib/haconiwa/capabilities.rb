require 'haconiwa/small_libcap'

module Haconiwa
  class Capabilities
    def initialize
      @blacklist = []
      @whitelist = []
    end

    def allow(*keys)
      if keys.first == :all
        @whitelist.clear
      else
        @whitelist.concat(keys)
      end
    end

    def drop(*keys)
      @blacklist.concat(keys)
    end

    def apply!
      if acts_as_whitelist?
        SmallLibcap.apply_cap_whitelist(list: @whitelist.uniq)
      else
        @blacklist.uniq.each do |n|
          SmallLibcap.drop_cap_by_name(n)
        end
      end
    end

    private
    def acts_as_whitelist?
      ! @whitelist.empty?
    end
  end
end
