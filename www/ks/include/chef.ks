# Setup Chef in the post-install phase

cat <<-'GEMRC' > /etc/gemrc
gem: --no-ri --no-rdoc
GEMRC

gem install ruby-shadow
gem install chef

mkdir /root/chef

cat <<-'CONFIG' > /root/chef/config.rb
root = File.absolute_path(File.dirname(__FILE__))
file_cache_path root + '/cache'
cookbook_path root + '/cookbooks'
recipe_url "http://<!--#echo var="SERVER_NAME" -->/bin/recipes.cgi"
# vim: ts=8 sw=4 sts=4
CONFIG

cat <<-'RUNLIST' > /root/chef/runlist.json
{
"run_list": [ "recipe[repo::default]" ]
}
RUNLIST
