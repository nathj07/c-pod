# Setup Chef in the post-install phase
# Note that the installation of Chef is now done prior to this via RPM

mkdir /etc/chef

cat <<'CONFIG' > /etc/chef/solo.rb
file_cache_path	'/var/chef/cache'
cookbook_path	'/var/chef/cookbooks'
recipe_url	'http://<!--#echo var="SERVER_NAME" -->/bin/recipes.cgi'
json_attribs	'/etc/chef/cpod.json'
verify_api_cert true
# vim: ts=8 sw=4 sts=4
CONFIG

cat <<'JSON' > /etc/chef/cpod.json
{
  "cpod": {
    "server_name": "<!--#echo var="SERVER_NAME" -->"
  },
  "run_list": [ "recipe[c-pod::client]" ]
}
JSON
