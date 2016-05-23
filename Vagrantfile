# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "puppetlabs/centos-7.0-64-puppet"

  config.vm.network "forwarded_port", guest: 80, host: 38080
  config.vm.network "private_network", ip: "192.168.98.10"
  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.provider "virtualbox" do |vbox|
    # Display the VirtualBox GUI when booting the machine
    vbox.gui = true

    # Customize the amount of memory on the VM:
    vbox.memory = "2048"
    vbox.cpus   = 4

    vbox.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    vbox.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    vbox.customize ["modifyvm", :id, "--nic2", "intnet"]
    vbox.customize ["modifyvm", :id, "--intnet2", "internal_network"]
  end

  config.vm.provision "shell", inline: <<-SHELL
    set -x
    if ! test -f ~vagrant/.rbenv/version; then
      sudo yum -y install epel-release
      sudo yum -y update
      sudo yum -y install libcgroup libcgroup-devel libcap-ng libcap-ng-devel
      sudo yum -y install gcc-c++ git glibc-headers libffi-devel libxml2 libxml2-devel \
                  libxslt libxslt-devel libyaml-devel make openssl-devel \
                  readline readline-devel sqlite-devel zlib zlib-devel
      git clone https://github.com/rbenv/rbenv.git ~vagrant/.rbenv
      ( cd ~vagrant/.rbenv && src/configure && make -C src )
      echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~vagrant/.bash_profile
      git clone https://github.com/rbenv/ruby-build.git ~vagrant/.rbenv/plugins/ruby-build
      . ~vagrant/.bash_profile
      rbenv install 2.2.5
      rbenv global 2.2.5
      rbenv rehash

      sudo yum -y install lxc lxc-templates lxc-doc lxc-libs rsync debootstrap
    fi
  SHELL
end
