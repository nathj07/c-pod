# Setup Chef in the post-install phase

cat <<'GEMRC' > /etc/gemrc
gem: -N --clear-sources --source http://<!--#echo var="SERVER_NAME" -->/gem_repo
GEMRC

gem install ruby-shadow
gem install chef

mkdir /etc/chef

cat <<'CONFIG' > /etc/chef/solo.rb
file_cache_path	'/var/chef/cache'
cookbook_path	'/var/chef/cookbooks'
# Fetch recipes from the master branch (this should be production for production machines)
recipe_url	'http://<!--#echo var="SERVER_NAME" -->/bin/recipes.cgi/master'
json_attribs	'/etc/chef/seu_runtime.json'
# vim: ts=8 sw=4 sts=4
CONFIG

cat <<'JSON' > /etc/chef/seu_runtime.json
{
  "run_list": [ "recipe[ip::yum_repo_conf]", "recipe[ip::seu_runtime]" ]
}
JSON
