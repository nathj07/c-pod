# Vagrantfile for a C-Pod repository
#
# The cloned images will be copied to the .vagrant directory by default
# Set VAGRANT_VMWARE_CLONE_DIRECTORY if you want to put them somewhere to avoid backups
#
#
Vagrant.configure("2") do |config|

  config.vm.define "cpod"

  # See https://docs.vagrantup.com/v2/vmware/boxes.html to create own box
  #
  boxes = { 
    c6:   'chef/centos-6.5', # Can't find bsdtar
    c7:   'chef/centos-7.0', # Broken as at 26/11/14: waits for HGFS to load
    u14:  'chef/ubuntu-14.04',
    p14:  'phusion/ubuntu-14.04-amd64', # tested OK 26/11/2014, required apache restart
    n14:  'nick/ubuntu14',
    n7:   'nick/centos7' # Working!
  }
  config.vm.box = boxes[:n7]
  config.vm.box_check_update = true

  # Configure the C-Pod via Chef JSON attributes
  #
  cpod_config = { cpod: {} }
  cpod_config[:cpod][:owner_name] = 'vagrant'
  cpod_config[:cpod][:server_name] = 'cpod.local'

  # Mount the data if it exists, otherwise it will be created in the VM
  #
  if Dir.exist? "../cpoddata"
    config.vm.synced_folder "../cpoddata", "/cpoddata"
    cpod_config[:cpod][:datadir] = "/cpoddata"
  end

  config.vm.hostname = cpod_config[:cpod][:server_name]

  config.vm.network "public_network"

  config.ssh.forward_agent = true

  config.vm.provider "vmware_fusion" do |vm, override|
    vm.gui = false
    vm.vmx["memsize"] = "512"
    vm.vmx["numvcpus"] = "1"
  end

  # Setup root key access
  #
  keys = []
  require 'open-uri'
  if (userkey = File.open("https://github.com/#{`logname`.strip}", &:read) rescue nil)
     keys << userkey
  end

  if (authkeys = File.open("#{ENV['HOME']}/.ssh/authorized_keys", &:read) rescue nil)
     keys << authkeys
  end

  if keys.size > 0
    config.vm.provision "shell",
      inline: <<-INLINE
        install -d -m 700 /root/.ssh
        echo -e "#{keys.join('\n')}" > /root/.ssh/authorized_keys
        chmod 0600 /root/.ssh/authorized_keys
        echo Installed your authorized keys for root access
        INLINE
  end

  # Chef

  config.omnibus.chef_version = :latest # "11.4.0"

  config.vm.provision "chef_solo" do |chef|
     chef.cookbooks_path = "chef/cookbooks"
     chef.add_recipe "c-pod::repo_host"
     chef.json = cpod_config
  #  chef.arguments = '--log_level=debug'
  end

  # Avahi needs a kick as the '.local' name isn't advertized...

  config.vm.provision "shell", inline: "service avahi-daemon restart"

end

# vim: ft=ruby sts=2 sw=2 ts=8
