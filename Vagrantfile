# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"

  # The URL to a precise64 box, if it doesn't already exist on the system,
  # it will be downloaded.
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Override for vmware
  config.vm.provider "vmware_fusion" do |v, override|
    override.vm.box_url = "http://files.vagrantup.com/precise64_vmware_fusion.box"
  end

  # For Virtualbox, we want to use more memory.
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", 512]
  end

  # The box settings
  config.vm.define :web do |web|
    # This is the IP we will use to access the VM while it's running.
    web.vm.network "forwarded_port", guest: 3000, host: 5000

    # NFS is faster for shared folders
    web.vm.synced_folder ".", "/vagrant", :nfs => true

    # Start the shell provisioner, which configures the machine for use
    web.vm.provision :shell, :path => "provision.sh"
  end

end
