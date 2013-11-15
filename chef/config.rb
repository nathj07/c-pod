# chef-solo config for developing locally
# Usage: chef-solo -c config.rb -o recipe[acookbook::arecipe]
#
root = File.absolute_path(File.dirname(__FILE__))
file_cache_path root + '/cache'
cookbook_path root + '/cookbooks'
