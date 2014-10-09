#!/usr/bin/env ruby 
#
# Create a recipe tgz file for remote chef-solo installs
# This is built from two sources:
#
# * The repo peer level directory 'cookbooks' - which should be a Git repository
#   This is extracted using git-archive, allowing us to specify which branch
#   to use as path info on the URL.
#   Normally this will be a branch eg. 'production' but can
#   also be any valid tree-ish. If not passed then the current
#   working directory is used (which is handy for testing changes)
#   NOTE This does require bsdtar
#
# * The repo directory 'chef/cookbooks' contents as-is
#
require 'cgi'
require 'shellwords'

base = File.absolute_path('../..', File.dirname(__FILE__))
cgi = CGI.new
if /\/(?<pathinfo>.+)/ =~ cgi.path_info
    treeish = pathinfo.shellescape
    unless system("cd #{base}/cookbooks && git rev-parse --verify #{treeish} > /dev/null 2>&1")
	cgi.out('status' => 'NOT_FOUND', 'Content-Type' => 'text/plain') do
	  "git tree-ish '#{treeish}' not found in #{base}/cookbooks"
	end
	exit 2
    end
    archive_cmd = "cd #{base}/cookbooks && git archive --prefix=cookbooks/ --format=tgz #{treeish} 2>/dev/null"
    cmd = "(#{archive_cmd}) | bsdtar -cz --exclude='*/.git*' -f - -C #{base}/c-pod/chef cookbooks @-"
else
    cmd = "bsdtar -cz --exclude='*/.git*' -f- -C #{base}/c-pod/chef cookbooks -C #{base} cookbooks"
end
cgi.out('Content-Disposition' => 'attachment; filename=recipes.tgz',
	'Content-Type' => 'application/octet-stream') do
  `#{cmd}`
end

# vim: sts=4 sw=4 ts=8 et
