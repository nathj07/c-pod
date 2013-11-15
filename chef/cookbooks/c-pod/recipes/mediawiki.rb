# A Recipe to setup MediaWiki
#
include_recipe "repo::apache"
include_recipe "repo::postgres"

node.default[:base] = '/data'
node.default[:mediawiki][:user] = 'packager'
node.default[:mediawiki][:group] = 'apache'
node.default[:mediawiki][:home] = "#{node[:base]}/mediawiki"

wikihome = node[:mediawiki][:home]

%w{ php php-xml php-pgsql }.each do |p|
    yum_package p
end

directory wikihome do
    recursive true
    owner   node[:mediawiki][:user]
    group   node[:mediawiki][:group]
    mode    02770
end

git "#{wikihome}/core" do
    repository "https://gerrit.wikimedia.org/r/p/mediawiki/core.git"
    reference "master"
    action :checkout # don't sync - do this manually
    notifies :run, "execute[repo_permissions]", :immediate
    group node[:mediawiki][:group]
    retries 2
end

# Git repos come out 644 and 755 so fix group permissions
execute "repo_permissions" do
    action :nothing
    command "chmod -R g+w #{wikihome}/core"
end

directory "#{wikihome}/extensions" do
    owner   node[:mediawiki][:user]
    group   node[:mediawiki][:group]
    mode    02770
end

directory "/var/cache/mediawiki" do
    owner   node[:mediawiki][:user]
    group   node[:mediawiki][:group]
    mode    02770
end

link "#{wikihome}/cache" do
    to "/var/cache/mediawiki"
end

directory "#{node[:base]}/upload" do
    owner   node[:mediawiki][:user]
    group   node[:mediawiki][:group]
    mode    02770
end

link "#{wikihome}/upload" do
    to "#{node[:base]}/upload"
end

# Setup the DB access
#
execute "createuser" do
    path    [node[:postgres][:bindir]]
    command %Q{psql -c "create user #{node[:mediawiki][:user]} with nocreatedb nocreaterole nosuperuser encrypted password 'secret'"}
    user    node[:postgres][:user]
    not_if  "psql -tc '\\du' | /bin/grep -q #{node[:mediawiki][:user]}", :user => node[:postgres][:user], :environment => { 'PATH' => node[:postgres][:bindir] }
end

execute "createdb" do
    path    [node[:postgres][:bindir]]
    command "createdb -O #{node[:mediawiki][:user]} mediawiki"
    user    node[:postgres][:user]
    not_if  "psql -l | /bin/grep -q mediawiki", :user => node[:postgres][:user], :environment => { 'PATH' => node[:postgres][:bindir] }
end

# Onetime setup - initialize the DB, save config in /root as we use our own
# Note although this step doesn't actually create the live LocalSettings
# we guard it using that.
#
execute "setup_mediawiki" do
    action :run
    creates "#{wikihome}/core/LocalSettings.php"
    cwd	"#{wikihome}/core"
    command <<-INSTALLCMD
    php maintenance/install.php \
	--server=http://#{node[:fqdn]} \
	--dbuser=#{node[:mediawiki][:user]} \
	--dbpass=secret \
	--confpath=/root \
	--dbname=mediawiki \
	--dbport=5432 \
	--dbserver=localhost \
	--dbtype=postgres \
	--installdbpass=secret \
	--installdbuser=#{node[:mediawiki][:user]}\
	--lang=en \
	--pass=secret C-Pod #{node[:mediawiki][:user]}
INSTALLCMD
end

# Setup Extensions
#
extensions = {
    :DynamicPageList => <<-DD.split("\n"),
#
# Setup DPL
#
ExtDynamicPageList::setFunctionalRichness(4);
ExtDynamicPageList::$options['userdateformat'] = array('default' => 'd M H:i');
DD
    :Gadgets => [],
    :Math => [],
    :Nuke => [],
    :ParserFunctions => [],
    :Poem => [],
    :Renameuser => [],
    :SyntaxHighlight_GeSHi => [],
    :Vector => []
}

# Create git-hosted extensions
#
extconfig = []
extensions.each do |extension, opts|
    git "#{wikihome}/#{extension}" do
	repository "https://gerrit.wikimedia.org/r/p/mediawiki/extensions/#{extension}.git"
	reference "master"
	action :checkout # don't sync - do this manually
	group node[:mediawiki][:group]
	retries 2
    end
    link "#{wikihome}/core/extensions/#{extension}" do
	to "#{wikihome}/#{extension}"
    end
    extconfig.push %{require_once( "$IP/extensions/#{extension}/#{extension}.php" );}
    extconfig += opts
end

# Create our own extensions
#
['yUML', 'WebSequenceDiagram'].each do |extension|
    directory "#{wikihome}/#{extension}" do
	owner   node[:mediawiki][:user]
	group   node[:mediawiki][:group]
	mode    02770
    end
    cookbook_file "#{wikihome}/#{extension}/#{extension}.php" do
	owner   node[:mediawiki][:user]
	group   node[:mediawiki][:group]
	mode    0660
    end
    link "#{wikihome}/core/extensions/#{extension}" do
	to "#{wikihome}/#{extension}"
    end
    extconfig.push %{require_once( "$IP/extensions/#{extension}/#{extension}.php" );}
end

template "#{wikihome}/core/LocalSettings.php" do
    action  :create
    mode    0664
    owner   node[:mediawiki][:user]
    group   node[:mediawiki][:group]
    variables( 
	:extensions => extconfig
    )
    notifies :restart, "service[httpd]", :delayed
end

# Apache Setup
#
file '/etc/httpd/conf.d/mediawiki.conf' do
    content <<-CONF
	<Directory "#{wikihome}">
	    Options Indexes FollowSymLinks
	    Order allow,deny
	    Allow from all
	    AllowOverride None
	</Directory>
	Alias /w #{wikihome}/core/index.php
	Alias /mediawiki/ #{wikihome}/core/
	DirectoryIndex index.html index.php index.html.var
	CONF
    notifies :restart, "service[httpd]", :delayed
end

# Use GraphicsMagick instead of ImageMagick, (no X11 dependencies and (allegedly) faster)
# Since MediaWiki uses the 'convert' command, create links
#
yum_package 'GraphicsMagick'

%w{ mogrify montage animate conjure identify display import composite convert }.each do |util|
    link "/usr/bin/#{util}" do
	to '/usr/bin/gm'
    end
end

# vim: sts=4 sw=4 ts=8
