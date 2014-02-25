# Setup the yum definitions we need for the C-Pod itself
# These include EPEL and RPMForge
# Note that a client system has it's own recipe: client_repo.conf
#

case osver
    when 5...6
    yum_package 'yum-priorities'
    rpms = %w{
	http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm
	http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
    }
    when 6...7
    yum_package 'yum-plugin-priorities'
    rpms = %w{
	http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
	http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
    }
end

require 'uri'

rpms.each do |rpmurl|
    filename = File.basename(URI(rpmurl).path)
    pkgname = filename.slice /\A(.*)-\d[^-]*-\d[^-]*?\./, 1
    pkgondisk =  "/root/#{filename}"
    remote_file pkgondisk do
	source rpmurl
	action	:create_if_missing
    end
    rpm_package pkgname do
	source pkgondisk
	action	:install
	notifies :run, "execute[create-yum-cache]", :delayed
	notifies :create, "ruby_block[reload-internal-yum-cache]", :delayed
    end
end

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

# vim: sts=4 sw=4 ts=8
