# Setup Chef config files to configure a C-Pod from the local clone
# This means that issuing the command 'chef-solo' will just work
#

directory "/etc/chef" do
    mode 2770
    group   node[:cpod][:owner_name]
end

template "/etc/chef/c-pod.json" do
    mode    0664
    group   node[:cpod][:owner_name]
end

template "/etc/chef/solo.rb" do
    action  :create
    mode    0664
    group   node[:cpod][:owner_name]
end

