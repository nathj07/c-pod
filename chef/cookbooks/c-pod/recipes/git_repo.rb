# Setup the C-Pod Git repository
#
cpod_user = node[:cpod][:owner_name]
basedir=node[:cpod][:base]

package 'git'

git "#{basedir}/c-pod" do
    repository "https://github.com/townsen/c-pod.git"
    reference "master"
    enable_submodules true
    action :checkout # don't sync - do this manually
    group cpod_user
    notifies :run, "execute[repo_permissions]", :immediate
end

# Git repos come out 644 and 755 so fix group permissions
execute "repo_permissions" do
    action :nothing
    command "chmod 02770 #{basedir}/c-pod && " \
	    "chmod -R g+w #{basedir}/c-pod && " \
	    "chown -R #{cpod_user}.#{cpod_user} #{basedir}/c-pod"
end

# vim: sts=4 sw=4 ts=8
