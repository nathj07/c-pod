file_cache_path '/var/chef/cache'
cookbook_path   '/var/chef/cookbooks'
# By default fetch recipes from the master (development) branch.
# This should be changed to production on production machines.
recipe_url      'http://<!--#echo var="SERVER_NAME" -->/bin/recipes.cgi/master'
json_attribs    '/etc/chef/runtime.json'
