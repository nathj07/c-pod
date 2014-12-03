# Setup the filesystem structure for a C-Pod Repository webserver
#
require 'json'

datadir = node[:cpod][:datadir]
repodir = node[:cpod][:repodir]
user    = node[:cpod][:owner_name]

# Setup the datadir
#
directory datadir do
    not_if { Dir.exist? datadir }
    owner user
    group user
    mode 02775
end

cookbook_file "#{datadir}/README" do
    action :create_if_missing
    source  'README.data'
    mode    0644
    owner   user
    group   user
end

# Setup the YUM repository directories
#
bash 'setup_repo' do
    code    "install -m 02770 -o #{user} -g #{user} -d #{datadir}/yum_repos/{,{lifted,stable,unstable}/{,{5,6,7}/{,{noarch,x86_64}}}}"
end

# Setup the GEM repository directories
#
bash 'setup_gem_repo' do
    code    "install -m 02770 -o #{user} -g #{user} -d gem_repo/{,gems}"
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
    link "#{repodir}/www/#{dir}" do
        to  "#{datadir}/#{dir}"
    end
end

link "#{repodir}/www/gems" do
    to  "#{datadir}/gem_repo/gems"
end

link "#{repodir}/bin/netmask_table" do
    to  "#{datadir}/netmask_table"
end

link "#{repodir}/www/cpod.pac" do
    to  "#{datadir}/cpod.pac"
end

file "#{datadir}/cpod.json" do
    action :create
    content node[:cpod].to_hash.to_json # this only gets one level! CHEF-3857
    mode    0664
    owner   user
    group   user
end

link "#{repodir}/www/cpod.json" do
    to  "#{datadir}/cpod.json"
end

datalink = File.absolute_path("../cpoddata", repodir)

link datalink do
    not_if  { File.exist? datalink }
    to      datadir
end

# vim: sts=4 sw=4 ts=8
