# Setup Chef in the post-install phase

cat <<'GEMRC' > /etc/gemrc
gem: --no-document --clear-sources --source http://<!--#echo var="SERVER_NAME" -->/gem_repo
GEMRC

gem install ruby-shadow
gem install chef

mkdir /etc/chef

cat <<'CONFIG' > /etc/chef/solo.rb
file_cache_path	'/var/chef/cache'
cookbook_path	'/var/chef/cookbooks'
recipe_url	'http://<!--#echo var="SERVER_NAME" -->/bin/recipes.cgi'
json_attribs	'/etc/chef/default.json'
# vim: ts=8 sw=4 sts=4
CONFIG

cat <<'JSON' > /etc/chef/default.json
{
  "run_list": [ "recipe[c-pod::client]" ]
}
JSON
