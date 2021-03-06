# chef-solo config for developing locally using definitions
# in this repository.
# Usage: chef-solo -c solo.rb -o recipe[acookbook::arecipe]
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
verify_api_cert	    true
