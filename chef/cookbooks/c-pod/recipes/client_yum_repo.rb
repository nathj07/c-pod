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

# Create the Yum repository configuration for the C-Pod server
# from the server itself.
# The primary definition of this is in the samples directory
# served by the C-Pod server and used during Kickstart.
# Keep things DRY: Don't put it in a template
#
remote_file '/etc/yum.repos.d/c-pod.repo' do
    action :create
    source 'http://localhost/samples/c-pod.repo'
    notifies :run, "execute[create-yum-cache]", :immediately
    notifies :create, "ruby_block[reload-internal-yum-cache]", :immediately
end

# vim: sts=4 sw=4 ts=8
