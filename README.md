# Hakoniwa

[![Build Status](https://travis-ci.org/udzura/hakoniwa.svg?branch=master)](https://travis-ci.org/udzura/hakoniwa)

Ruby on Container / helper tools with DSL for your handmade linux containers

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hakoniwa'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hakoniwa

## Usage

```ruby
require "hakoniwa"

hakoniwa = Hakoniwa::Base.define do |config|
  config.name = "new-hakoniwa001" # to be hostname

  config.cgroup["cpu.shares"] = 2048
  config.cgroup["memory.limit_in_bytes"] = "256M"
  config.cgroup["pid.max"] = 1024

  config.chroot_to "/var/your_rootfs"
  config.add_mount_point "/var/another/root/etc", to: "/etc", readonly: true
  config.add_mount_point "/var/another/root/home", to: "/home"
  config.add_mount_point "proc", to: "/proc", fs: "proc"

  config.namespace.unshare "ipc"
  config.namespace.unshare "mount"
  config.namespace.unshare "pid"
  config.namespace.use_netns "foobar"

  config.capabilities.allow :all
  config.capabilities.drop "CAP_SYS_TIME"
end

hakoniwa.start

## or to attach running container

Hakoniwa.attach hakoniwa.name
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/udzura/hakoniwa. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

