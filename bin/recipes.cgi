#!/usr/bin/env ruby 
#
# Create a recipe tgz file for remote chef-solo installs
#
require 'cgi'

repo = File.absolute_path('..', File.dirname(__FILE__))
cmd = "tar -cz -f- -C #{repo}/chef cookbooks"
CGI.new.out('Content-Disposition' => 'attachment; filename=recipes.tgz',
	'Content-Type' => 'application/octet-stream') do
  `#{cmd}`
end

# vim: sts=4 sw=4 ts=8
