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
  boxes = { c6: 'chef/centos-6.5', # Can't find bsdtar
            c7: 'chef/centos-7.0', # Broken as at 26/11/14: waits for HGFS to load
            u14: 'chef/ubuntu-14.04',
            p14: 'phusion/ubuntu-14.04-amd64', # tested OK 26/11/2014, required apache restart
            n7: 'nick/centos7'
          }
  config.vm.box = boxes[:n7]
  config.vm.box_check_update = true

  config.vm.hostname = 'cpod.local'

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Use 'override' to override the 'config' variable
  config.vm.provider "vmware_fusion" do |vm, override|
    vm.gui = false
    vm.vmx["memsize"] = "1024"
    vm.vmx["numvcpus"] = "2"
  end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  # Install Chef
  config.omnibus.chef_version = :latest # "11.4.0"

  # Configure the C-Pod via Chef JSON attributes
  #
  cpod_config = { cpod: {} }
  cpod_config[:cpod][:owner_name] = 'vagrant'

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  #
  if Dir.exist? "../c-pod_data"
    config.vm.synced_folder "../c-pod_data", "/cpoddata"
    cpod_config[:cpod][:datadir] = "/cpoddata"
  end
  require 'open-uri'
  if (userkey = File.open("https://github.com/#{`logname`.strip}", &:read) rescue nil)
     cpod_config[:cpod][:ssh_key] = userkey
  end
  #
  if (keys = File.open("#{ENV['HOME']}/.ssh/authorized_keys", &:read) rescue nil)
    config.vm.provision "shell",
      inline: <<-INLINE
        install -d -m 700 /root/.ssh
        echo "#{keys}" > /root/.ssh/authorized_keys
        chmod 0600 /root/.ssh/authorized_keys
        echo Installed your authorized keys for root access
        INLINE
  end

  config.vm.provision "chef_solo" do |chef|
     chef.cookbooks_path = "chef/cookbooks"
     chef.add_recipe "c-pod::repo_host"
     chef.json = cpod_config
  #  chef.arguments = '--log_level=debug'
  end

end

# vim: ft=ruby sts=2 sw=2 ts=8
