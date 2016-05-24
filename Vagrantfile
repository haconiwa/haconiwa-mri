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

  config.vm.provision "shell", inline: (<<-SHELL).gsub(/^ +/m, "")
    set -x
    if ! test -f /usr/local/rbenv/version; then
      sudo bash -l << EOS
        yum -y install epel-release
        yum -y update
        yum -y install libcgroup libcgroup-devel libcap-ng libcap-ng-devel
        yum -y install gcc-c++ git glibc-headers libffi-devel libxml2 libxml2-devel \
          libxslt libxslt-devel libyaml-devel make openssl-devel \
          readline readline-devel sqlite-devel zlib zlib-devel
        git clone https://github.com/rbenv/rbenv.git /usr/local/rbenv
        ( cd /usr/local/rbenv && sudo src/configure && sudo make -C src )
        echo 'export PATH="/usr/local/rbenv/bin:$PATH"' | tee -a /etc/profile.d/rbenv.sh
        echo 'eval "$(rbenv init -)"' | tee -a /etc/profile.d/rbenv.sh
        git clone https://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build
        . /etc/profile.d/rbenv.sh
        rbenv install 2.2.5
        rbenv global 2.2.5
        rbenv rehash

        yum -y install lxc lxc-templates lxc-doc lxc-libs rsync debootstrap

        mkdir /var/haconiwa
        mkdir /var/haconiwa/root
        mkdir /var/haconiwa/rootfs
        mkdir /var/haconiwa/bundle
        mkdir /var/haconiwa/user_homes
    EOS
    fi
  SHELL
end
