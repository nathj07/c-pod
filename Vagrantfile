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
  boxes = { c6: 'chef/centos-6.5', 
            c7: 'chef/centos-7.0', 
            u14: 'chef/ubuntu-14.04',
            p14: 'phusion/ubuntu-14.04-amd64',
            n7: 'nick/centos7'
          }
  config.vm.box = boxes[:p14]
  config.vm.hostname = 'cpod.local'

  config.vm.box_check_update = true
  # config.vm.box_url = 

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

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # use 'override' as a config variable to override it
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
  #  chef.roles_path = "../my-recipes/roles"
  #  chef.data_bags_path = "../my-recipes/data_bags"
     chef.add_recipe "c-pod::repo_host"
  #  chef.add_role "web"
     chef.json = { cpod: { github_key: "#{`logname`.strip}" } }
  #  chef.arguments = '--log_level=debug'
  end

end

# vi: set ft=ruby :
