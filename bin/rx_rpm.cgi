#!/usr/bin/env ruby 
#
# Receive an RPM file, place in the repo and rebuild
#
require 'cgi'
require 'tempfile'
require 'stringio'
require 'fileutils'

$base = File.absolute_path('../..', File.dirname(__FILE__))

def repopath rpmname, status
    status = 'unstable' unless status == 'stable'
    raise "#{rpmname} isn't a recognizable RPM" unless /(?<package>^.*)-(?<pkginfo>.*)$/ =~ rpmname
    pkgparts = pkginfo.split '.'
    suffix = pkgparts.pop
    raise "Not an RPM: #{suffix}" unless suffix == 'rpm'
    arch = pkgparts.pop
    rel = if pkgparts.select { |c| c =~ /^el5$/ }.size > 0
	       '5'
	   elsif pkgparts.select { |c| c =~ /^el6$/ }.size > 0
	       '6'
	   else
	       '5' # put unlabelled ones in 5
	   end
    yum_repos = File.absolute_path('../../yum_repos', File.dirname(__FILE__))
    "#{$base}/yum_repos/custom/#{rel}/#{status}/#{arch}/#{rpmname}"
end

q = CGI.new

begin
    case q['rpmfile']
    when StringIO
	t = q['rpmfile']
	filename = t.original_filename
	IO.copy_stream t, repopath(filename, q['status'])
    when Tempfile
	t = q['rpmfile']
	filename = t.original_filename
	FileUtils.cp t.local_path, repopath(filename, q['status'])
	t.unlink
    else
	raise "You must POST an rpmfile! I got #{q['rpmfile'].inspect}"
    end
    rebuild_opts = q['force'] == "yes" ? "-f": ""
    rebuild = `#{$base}/repo/bin/rebuild_indexes -t yum #{rebuild_opts}`
    raise "Rebuild failed: #{rebuild}" unless $?.success?
    q.out('text/plain') { rebuild }
rescue Exception => e
    q.out 'status' => 'BAD_REQUEST' do
	q['debug'] == 'yes' ?
	    "#{e.message}\n#{e.backtrace.join('\n')}" :
	    e.message
    end
end

# vim: sts=4 sw=4 ts=8
