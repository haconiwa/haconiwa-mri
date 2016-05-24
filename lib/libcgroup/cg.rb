require 'ffi'
require 'libc'

module LibCgroup
  extend FFI::Library
  ffi_lib [FFI::CURRENT_PROCESS, 'cgroup', '/lib64/libcgroup.so.1']

  typedef :pointer, :cgroup
  typedef :pointer, :controller
  typedef :pointer, :FILE
  typedef :pointer, :FILE

  CGFLAG_USECACHE = 0x01
  #const_set ECGEOF

  ##
  # The application must initialize libcgroup using LibCgroup.init before any
  # other libcgroup function can be called. libcgroup caches information
  # about mounted hierarchies (just what's mounted where, not the control groups
  # themselves) at this time. There is currently no way to refresh this cache,
  # i.e. all subsequent mounts/remounts/unmounts are not reflected in this cache
  # and libcgroup may produce unexpected results.
  def self.init
    self.cgroup_init
  end

  ##
  # Returns path where is mounted given controller.
  # Only the first mount point is returned, use
  # LibCgroup.get_subsys_mount_point_begin(), LibCgroup.get_subsys_mount_point_next()
  # and LibCgroup.get_subsys_mount_point_end() to get all of them.
  #
  # controller Name of the controller
  #
  #   LibCgroup.init
  #    => 0 
  #   LibCgroup.get_subsys_mount_point("cpu")
  #    => "/sys/fs/cgroup" 
  #
  def self.get_subsys_mount_point(ctl)
    objptr = FFI::MemoryPointer.new :pointer
    self.cgroup_get_subsys_mount_point(ctl, objptr)
    strPtr = objptr.read_pointer
    return strPtr.null? ? "" : strPtr.read_string
  end

  ##
  # init.h
  attach_function :cgroup_init, [], :int
  attach_function :cgroup_get_subsys_mount_point, [:string, :pointer], :int

  ##
  # error.h
  attach_function :cgroup_strerror, [:int], :string

  ##
  # iterators.h

  ##
  # Detailed information about available controller.
  class ControllerData < FFI::Struct
    layout :name,        :string,
           :hierarchy,   :int,
           :num_cgroups, :int,
           :enabled,     :int
    # Controller name
    def name
      self[:name]
    end

	  # Hierarchy ID. Controllers with the same hierarchy ID
	  # are mounted together as one hierarchy. Controllers with
	  # ID 0 are not currently mounted anywhere.
    def hierarchy
      self[:hierarchy]
    end

    # Number of groups
    def num_cgroups
      self[:num_cgroups]
    end

    def enabled
      self[:enabled]
    end

    def self.release(ptr)
      LibC.free(ptr)
    end
  end

  typedef :pointer, :controller_data
  attach_function :cgroup_get_all_controller_begin, [:pointer, :controller_data], :int
  attach_function :cgroup_get_all_controller_next, [:pointer, :controller_data], :int
  attach_function :cgroup_get_all_controller_end, [:pointer], :int

  def self.each_controller(&block)
    handle = LibC.malloc 1024
    puts handle
    handle_p = FFI::MemoryPointer.new(handle)
    #cdptr = FFI::MemoryPointer.new ControllerData, ControllerData.size, true
    #cd = ControllerData.new cdptr
    cd = ControllerData.new
    self.cgroup_get_all_controller_begin(handle_p, cd.pointer)
    puts cd
    puts handle
    self.cgroup_get_all_controller_end(handle_p)
  end

  ##
  # tasks.h
  attach_function :cgroup_attach_task, [:cgroup], :int
  attach_function :cgroup_attach_task_pid, [:cgroup, :pid_t], :int
  attach_function :cgroup_init_rules_cache, [], :int
  attach_function :cgroup_reload_cached_rules, [], :int
  attach_function :cgroup_print_rules_config, [:FILE], :void

  ##
  # config.h
  attach_function :cgroup_config_load_config, [:string], :int
  attach_function :cgroup_unload_cgroups, [], :int
  attach_function :cgroup_config_unload_config, [:string, :int], :int
  attach_function :cgroup_config_set_default, [:string, :int], :int

  ##
  # groups.h
  attach_function :cgroup_new_cgroup, [:string], :cgroup
  attach_function :cgroup_get_cgroup, [:cgroup], :int
  attach_function :cgroup_add_controller, [:cgroup, :string], :controller
  attach_function :cgroup_get_controller, [:cgroup, :string], :controller
  attach_function :cgroup_free, [:pointer], :void
  attach_function :cgroup_free_controllers, [:cgroup], :void
  attach_function :cgroup_get_value_name, [:controller, :int], :string
  attach_function :cgroup_get_value_name_count, [:controller], :int
  attach_function :cgroup_get_value_string, [:controller, :string, :pointer], :int
end

