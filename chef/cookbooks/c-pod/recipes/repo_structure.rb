# Setup the filesystem structure for a C-Pod Repository webserver
#
datadir = node[:cpod][:datadir]
basedir = node[:cpod][:base]
user = node[:cpod][:owner_name]

# Setup the YUM repository directories
#
bash 'setup_repo' do
    code    "install -m 02770 -o #{user} -g #{user} -d #{datadir}/yum_repos/{lifted,stable,unstable}/{5,6,7}/{noarch,x86_64}"
end

# Setup the GEM repository directories
#
bash 'setup_gem_repo' do
    code    "install -m 02770 -o #{user} -g #{user} -d gem_repo/gems"
    cwd     datadir
end

# Setup the other directories
#
bash 'setup_other_dirs' do
    code    "install -m 02770 -o #{user} -g #{user} -d {cookbooks,downloads,osmirror}"
    cwd     datadir
end

# Setup the links
#
%w{ downloads gem_repo osmirror yum_repos }.each do |dir|
    link "#{basedir}/c-pod/www/#{dir}" do
        to  "#{datadir}/#{dir}"
    end
end
link "#{basedir}/c-pod/www/gems" do
    to  "#{datadir}/gem_repo/gems"
end

# vim: sts=4 sw=4 ts=8
