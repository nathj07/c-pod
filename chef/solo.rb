# chef-solo config for developing locally
# Usage: chef-solo -c config.rb -o recipe[acookbook::arecipe]
# See: http://docs.opscode.com/config_rb_solo.html
#
base = File.absolute_path(File.dirname(__FILE__))
cookbook_path base + '/cookbooks'
# Overspecify these as the default /var doesn't play well on MacOSX
root = '/tmp/chef'
data_bag_path       root + '/databags'
environment_path    root + '/environments'
file_backup_path    root + '/backup'
file_cache_path     root + '/cache'
node_path           root + '/node'
role_path           root + '/roles'
