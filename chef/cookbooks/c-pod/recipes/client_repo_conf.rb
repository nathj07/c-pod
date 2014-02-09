# Setup the C-Pod client yum definitions
# and rebuild the client yum cache
#

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

case osver
    when 5...6
    yum_package 'yum-priorities'
    when 6...7
    yum_package 'yum-plugin-priorities'
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
