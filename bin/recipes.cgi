#!/usr/bin/env ruby 
#
# Create a recipe tgz file for remote chef-solo installs
# Note that the treeish required is passed as path info
# Normally this will be a branch eg. 'production' but can
# also be any valid tree-ish. It defaults to master
#
require 'cgi'
require 'shellwords'

repo = File.absolute_path('..', File.dirname(__FILE__))
cgi = CGI.new
if /\/(?<pathinfo>.+)/ =~ cgi.path_info
    treeish = pathinfo.shellescape
    unless system("cd #{repo} && git rev-parse --verify #{treeish} > /dev/null 2>&1")
	cgi.out('status' => 'NOT_FOUND', 'Content-Type' => 'text/plain') do
	  "git tree-ish '#{treeish}' not found in #{repo}"
	end
	exit 2
    end
else
    treeish = 'master'
end
cmd = "cd #{repo} && git archive --format=tgz #{treeish} chef 2>/dev/null | bin/tarstrip -s 1"
cgi.out('Content-Disposition' => 'attachment; filename=recipes.tgz',
	'Content-Type' => 'application/octet-stream') do
  `#{cmd}`
end

# vim: sts=4 sw=4 ts=8 et
