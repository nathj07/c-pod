# Setup Chef config files to configure a C-Pod from the local clone
#

directory "/etc/chef" do
    mode 0750
end

template "/etc/chef/solo.rb" do
    action  :create
    mode    0644
    variables( :base => node[:cpod][:base] )
end

