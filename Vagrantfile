# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "fedora-20-x86_64.box"
  config.vm.box_url = "https://dl.dropboxusercontent.com/s/ohazhdin4nibmx9/fedora-20-x86_64.box"

  config.vm.hostname = "dev.example.com"
  config.vm.network :private_network, ip: "10.10.10.10"

  config.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=777","fmode=777"]
  
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--name"  , "dev"]
    #vb.gui = true
  end

  config.vm.provision :puppet do |puppet|
      puppet.manifests_path    = "puppet/manifests"
      puppet.module_path       = "puppet/modules"
      puppet.manifest_file     = "site.pp"
      puppet.options           = "--verbose --hiera_config /vagrant/puppet/hiera.yaml"
  
      puppet.facter = {
        "environment"     => "development",
        "vm_type"         => "vagrant",
      }
  end

end