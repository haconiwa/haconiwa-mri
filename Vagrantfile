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

  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo yum -y install epel-release
  #   sudo yum -y update
  # SHELL
end
