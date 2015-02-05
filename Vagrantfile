# Vagrantfile for a C-Pod repository
#
# The cloned images will be copied to the .vagrant directory by default
# Set VAGRANT_VMWARE_CLONE_DIRECTORY if you want to put them somewhere to avoid backups
#
#
Vagrant.configure("2") do |config|

  config.vm.define "cpod"

  config.vm.box = 'townsen/ubuntu-14.10'
  config.vm.box_check_update = true

  # Configure the C-Pod via Chef JSON attributes
  #
  cpod_config = { cpod: {} }
  cpod_config[:cpod][:owner_name]   = 'vagrant'
  cpod_config[:cpod][:server_name]  = 'cpod.local'
  cpod_config[:cpod][:repodir]      = '/vagrant'

  # Mount the data if it exists, otherwise it will be created in the VM
  #
  if Dir.exist? "../cpoddata"
    cpod_config[:cpod][:datadir] = "/srv/cpoddata"
    config.vm.synced_folder "../cpoddata", cpod_config[:cpod][:datadir]
  end

  # DON'T ADD .local as it then puts it in /etc/hosts as loopback address
  # which interferes with mDNS resolution
  config.vm.hostname = cpod_config[:cpod][:server_name].rpartition('.')[0]

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

  # Avahi needs a kick as the '.local' name isn't advertized...

  config.vm.provision "shell", inline: "service avahi-daemon restart && echo Avahi restarted"

  # Chef

  config.vm.provision "chef_solo" do |chef|
     chef.install = true
     chef.version = '11.16.4'
     chef.cookbooks_path = "chef/cookbooks"
     chef.add_recipe "c-pod::repo_host"
     chef.json = cpod_config
     chef.custom_config_path = "chef/vagrant_solo.conf"
  #  chef.arguments = '--log_level=debug'
  end

  config.vm.provision "shell",
    inline: <<-DOCKER
      cp /vagrant/docker/docker.defaults /etc/default/docker
      echo Use DOCKER_HOST=tcp://#{cpod_config[:cpod][:server_name]}.local:2375
    DOCKER

  config.vm.provision :docker do |d|
    d.version = :latest
    d.images  = ['centos:centos6','centos:centos7']
    d.build_image "/vagrant/docker/centos6", args: "-t 'townsen/rpmbuild:centos6'"
    d.build_image "/vagrant/docker/centos7", args: "-t 'townsen/rpmbuild:centos7'"
    d.run "townsen/rpmbuild6",
      image: "townsen/rpmbuild:centos6", cmd: "bash -l",
      args: "-i -t -h rpmbuilder6 -v '/vagrant:/home/townsen/c-pod'"
    d.run "townsen/rpmbuild7",
      image: "townsen/rpmbuild:centos7", cmd: "bash -l",
      args: "-i -t -h rpmbuilder7 -v '/vagrant:/home/rpmbuilder/c-pod'"
  end

end

# vim: ft=ruby sts=2 sw=2 ts=8
