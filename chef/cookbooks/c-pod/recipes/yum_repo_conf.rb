# Setup the yum definitions we need
#
yum_package (5...6).include?(osver) ? 'yum-priorities': 'yum-plugin-priorities'

execute "create-yum-cache" do
    command "yum -q makecache"
    action :nothing
end

ruby_block "reload-internal-yum-cache" do
    block do
	Chef::Provider::Package::Yum::YumCache.instance.reload
    end
    action :nothing
end

template '/etc/yum.repos.d/c-pod.repo' do
    action :create
    variables({
	:repo_host => "c-pod.sendium.net"
    })
    user "root"
    group "root"
    notifies :run, "execute[create-yum-cache]", :immediately
    notifies :create, "ruby_block[reload-internal-yum-cache]", :immediately
end

# vim: sts=4 sw=4 ts=8
