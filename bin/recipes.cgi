#!/usr/bin/env ruby 
#
# Create a recipe tgz file for remote chef-solo installs
# Includes subdirectories in:
# * the repo peer level directory 'cookbooks'
# * the repo directory 'chef/cookbooks'
#
require 'cgi'

base = File.absolute_path('../..', File.dirname(__FILE__))
cgi = CGI.new
cmd = "/bin/tar -chz --exclude='*/.git' -f- -C #{base} cookbooks -C #{base}/c-pod/chef cookbooks"
cgi.out('Content-Disposition' => 'attachment; filename=recipes.tgz',
	'Content-Type' => 'application/octet-stream') do
  `#{cmd}`
end

# vim: sts=4 sw=4 ts=8 et
