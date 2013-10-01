root = File.absolute_path(File.dirname(__FILE__))
file_cache_path root + '/cache'
cookbook_path root + '/cookbooks'
recipe_url "http://<!--#echo var="SERVER_NAME" -->/bin/recipes.cgi"
