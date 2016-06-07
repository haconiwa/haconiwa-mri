# Haconiwa

[![Build Status](https://travis-ci.org/haconiwa/haconiwa.svg?branch=master)](https://travis-ci.org/haconiwa/haconiwa) [![Gem Version](https://badge.fury.io/rb/haconiwa.svg)](https://badge.fury.io/rb/haconiwa)

Ruby on Container / helper tools with DSL for your handmade linux containers

## Installation

This gem only works on Linux systems, as using cgroup, Linux namespace and Linux capabilities.

Some packages/dylibs/tools are used internally, so please install below before gem setup:

* `libcap` (`libcap.so.2` is used via FFI)
* `nsenter` (e.g. `yum install util-linux` or such one)

Then, install it yourself globally(recommended using rbenv) as:

```console
$ gem install haconiwa
$ rbenv rehash # if needed
```

Or add the line to your application's Gemfile:

```ruby
gem 'haconiwa'
```

And then execute `bundle`.

## Usage

Create the file `example001.haco`:

```ruby
Haconiwa::Base.define do |config|
  config.name = "new-haconiwa001" # to be hostname

  config.cgroup["cpu.shares"] = 2048
  config.cgroup["memory.limit_in_bytes"] = "256M"
  config.cgroup["pid.max"] = 1024

  config.add_mount_point "/var/another/root/etc", to: "/var/your_rootfs/etc", readonly: true
  config.add_mount_point "/var/another/root/home", to: "/var/your_rootfs/home"
  config.mount_independent_procfs
  config.chroot_to "/var/your_rootfs"

  config.namespace.unshare "ipc"
  config.namespace.unshare "uts"
  config.namespace.unshare "mount"
  config.namespace.unshare "pid"

  config.capabilities.allow :all
  config.capabilities.drop "CAP_SYS_TIME"
end
```

Then use `haconiwa` binary installed with thie gem.

```console
$ haconiwa run example001.haco
```

When you want to attach existing container:

```console
$ haconiwa attach example001.haco
```

Note: `attach` subcommand allows to set PID(`--target`) or container name(`--name`) for dynamic configuration.
And `attach` is not concerned with capabilities which is granted to container. So you can drop or allow specific caps with `--drop/--allow`.

### DSL spec

* `config.cgroup` - Assign cgroup parameters via `[]=`
* `config.namespace.unshare` - Unshare the namespaces like `"mount"`, `"ipc"` or `"pid"`
* `config.capabilities.allow` - Allow capabilities on container root. Setting parameters other than `:all` should make this acts as whitelist
* `config.capabilities.drop` - Drop capabilities of container root. Default to act as blacklist
* `config.add_mount_point` - Add the mount point odf container
* `config.mount_independent_procfs` - Mount the independent /proc directory in the container. Useful if `"pid"` is unshared
* `config.chroot_to` - The new chroot root

You can pick your own parameters for your use case of container.
e.g. just using `mount` namespace unshared, container with common filesystem, limit the cgroups for big resource job and so on.

Please look into `example` directory.

### Library use case

```ruby
require 'haconiwa'
base = Haconiwa::Base.define do |config|
  config.name = "new-haconiwa001" # to be hostname
  ...
end

# Run the container
base.run("/bin/bash")

# Or attach existing one
base.attach("/bin/bash")
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/udzura/haconiwa. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## TODOs

* [ ] netns attachment
* [ ] more utilities such as `ps`
* [ ] better daemon handling

## License

This gem is created under [GNU General Public License Version 3](./LICENSE).

