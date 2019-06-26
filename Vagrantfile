# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box     = "suse/sles12sp2"

  config.vm.hostname = "dev.example.com"
  config.vm.network :private_network, ip: "10.10.10.10"

  config.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=777","fmode=777"]

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--name"  , "dev"]
    #vb.gui = true
  end

  config.vm.provision "shell", path: "puppet.sh"

  config.vm.provision :puppet do |puppet|
      puppet.binary_path       = "/opt/puppetlabs/bin"
      puppet.environment_path  = "puppet/environments"
      puppet.environment       = "development"
      puppet.module_path       = "puppet/modules"
#      puppet.manifest_file     = "site.pp"
      puppet.options           = [
                                  '--verbose',
                                  '--report',
                                  '--trace',
#                                  '--debug',
#                                  '--parser future',
#                                  '--strict_variables',
                                 ]
  end
end
