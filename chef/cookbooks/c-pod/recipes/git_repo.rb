# Setup the C-Pod Git repository
#
cpod_user   = node[:cpod][:owner_name]
repodir     = node[:cpod][:repodir]

package 'git'

git repodir do
    repository "https://github.com/townsen/c-pod.git"
    reference "master"
    enable_submodules true
    action :checkout # Only if it doesn't exist!
    group cpod_user
    notifies :run, "execute[repo_permissions]", :immediate
end

# Git repos come out 644 and 755 so fix group permissions
execute "repo_permissions" do
    action :nothing
    command "chmod 02770 #{repodir} && " \
	    "chmod -R g+w #{repodir} && " \
	    "chown -R #{cpod_user}.#{cpod_user} #{repodir}"
end

# vim: sts=4 sw=4 ts=8
