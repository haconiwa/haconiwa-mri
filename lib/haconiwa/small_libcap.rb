require 'ffi'

module Haconiwa
  class Cap_T < FFI::ManagedStruct
    layout :head, :pointer,
           :set, :pointer

    def self.release(ptr)
      SmallLibcap.cap_free ptr
    end
  end

  class SmallLibcap
    class CapError < StandardError; end

    extend FFI::Library
    ffi_lib "libcap.so.2"

    attach_function :cap_get_proc,   [], Cap_T.ptr
    attach_function :cap_set_proc,   [Cap_T.ptr], :int
    attach_function :cap_from_name,  [:string, :pointer], :int
    attach_function :cap_drop_bound, [:int], :int
    attach_function :cap_get_bound,  [:int], :int

    attach_function :cap_free, [:pointer], :int

    def self.cap_supported?(cap)
      cap_get_bound(cap) >= 0
    end

    def self.drop_cap_by_name(name)
      ptr = FFI::MemoryPointer.new(:int)
      err = cap_from_name(name, ptr)
      if err < 0
        raise CapError, "Invalid or unsupported capability name: #{name}"
      end

      err = cap_drop_bound(ptr.read_int)
      if err < 0
        raise CapError, "Failed to drop capability name: #{name} from bounding set"
      end
      true
    end
  end
end
