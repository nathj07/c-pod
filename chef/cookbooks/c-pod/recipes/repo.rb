# Setup the C-Pod Git repository
#
cpod_user = node[:cpod][:owner_name]
BASE=node[:cpod][:base]

git "#{BASE}/c-pod" do
    repository "git@github.com:townsen/c-pod.git"
    reference "master"
    action :checkout # don't sync - do this manually
    group cpod_user
    notifies :run, "execute[repo_permissions]", :immediate
    notifies :restart, "service[apache2]", :delayed
end

# Git repos come out 644 and 755 so fix group permissions
execute "repo_permissions" do
    action :nothing
    command "chmod 02770 #{BASE}/c-pod && " \
	    "chmod -R g+w #{BASE}/c-pod && " \
	    "chown -R #{cpod_user}.#{cpod_user} #{BASE}/c-pod"
end

# vim: sts=4 sw=4 ts=8
