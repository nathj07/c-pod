#!/usr/bin/env ruby
#
# Receive a GEM or RPM file, place in the appropriate repo and rebuild
#
require 'cgi'
require 'tempfile'
require 'stringio'
require 'fileutils'

File.umask(0002)
$repo = File.absolute_path('..', File.dirname(__FILE__))
$base = File.absolute_path('../..', File.dirname(__FILE__))

def repopath pkgname, type
    type = 'unstable' if type == ''
    raise "#{pkgname} isn't a recognizable package" unless /(?<package>^.*)-(?<pkginfo>.*)$/ =~ pkgname
    pkgparts = pkginfo.split '.'
    suffix = pkgparts.pop
    case suffix
    when 'rpm'
	arch = pkgparts.pop
	rel = if pkgparts.select { |c| c =~ /^(rh)?el5(_.*)?$/ }.size > 0
		   '5'
	       elsif pkgparts.select { |c| c =~ /^(rh)?el6(_.*)?/ }.size > 0
		   '6'
	       else
		   '5' # put unlabelled ones in 5
	       end
	yum_repos = File.absolute_path('../../yum_repos', File.dirname(__FILE__))
	if ['stable','unstable'].include? type
	    "#{$base}/yum_repos/custom/#{rel}/#{type}/#{arch}/#{pkgname}"
	else
	    "#{$base}/yum_repos/#{type}/#{rel}/#{arch}/#{pkgname}"
	end
    when 'gem'
	"#{$base}/gem_repo/gems/#{pkgname}"
    else raise "Suffix #{suffix} is not a recognized package type"
    end
end

q = CGI.new

begin
    q.print q.header('text/plain') # TODO replace header with http_header for Ruby 2+
    if q.include?('pkgfile')
	t = q['pkgfile']
	filename = t.original_filename
	ofile = repopath(filename, q['type'])
	case t
	when StringIO
	    IO.copy_stream t, ofile
	when Tempfile
	    FileUtils.cp t.local_path, ofile
	    t.unlink
	else
	    raise "I unexpectedly got #{t.inspect}"
	end
	FileUtils.chmod 0660, ofile
	q.print "File uploaded to #{ofile}\n"
    end
    if q['rebuild'] == 'yes'
	rebuild_opts = q['force'] == "yes" ? "-f": ""
	rebuild = `#{$repo}/bin/rebuild_indexes #{rebuild_opts}`
	raise "Rebuild failed: #{rebuild}" unless $?.success?
	q.print rebuild
    end
rescue Exception => e
    q.out 'status' => 'BAD_REQUEST' do
	q['debug'] == 'yes' ?
	    "#{e.message}\n#{e.backtrace.join('\n')}" :
	    e.message
    end
end

# vim: sts=4 sw=4 ts=8
