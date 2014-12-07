#!/usr/bin/env ruby
#
# Receive a GEM or RPM file, place in the appropriate repo and rebuild
#
require 'cgi'
require 'tempfile'
require 'stringio'
require 'fileutils'
require_relative 'funcs.rb'

File.umask(0002)
$repo = File.absolute_path('..', File.dirname(__FILE__))
$data = File.absolute_path('../../cpoddata', File.dirname(__FILE__))

def warn msg
    "\033[31m#{msg}\033[0m"
end

# Return the path on disk for this package and the base name
#
def repopath package, type, rhel
    type = 'unstable' if type == ''
    pkginfo = parsepkg package, rhel
    path = case pkginfo[:format]
    when 'rpm'
        "#{$data}/yum_repos/#{type}/#{pkginfo[:rhel]}/#{pkginfo[:arch]}"
    when 'gem'
	"#{$data}/gem_repo/gems"
    else
        raise "Format #{pkginfo[:format]} is not a recognized package type"
    end
    return path, pkginfo[:name]
end

# Retain only the latest copies of the packages
#
def cleanup path, name, copies
    return "" if copies == -1
    files = Dir.glob("#{path}/#{name}*")
    files.select!{|f| /(?<pkgname>^.*)-(?<ver>\d[0-9\.]+\d)(?<pkginfo>.*)$/ =~ File.basename(f) and pkgname == name }
    files.sort!{|a,b| File.mtime(b) <=> File.mtime(a)}
    files.shift(copies - 1) if copies > 1
    files.each{|f| File.unlink f} 
    return warn "Deleted #{files.size} older versions of #{name} in path #{path}\n"
end

q = CGI.new

begin
    q.print q.header('text/plain') # TODO replace header with http_header for Ruby 2+
    if q.include?('pkgfile')
	t = q['pkgfile']
	filename = t.original_filename
	opath, pkgname = repopath(filename, q['type'],q['rhel'])
        copies = q.include?('keep') ? q['keep'].to_i : -1
        delmsg = cleanup opath, pkgname, copies
        if copies == 0
            q.print warn "Deleted all versions of #{pkgname} in path #{opath}\n"
        else
            ofile = "#{opath}/#{filename}"
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
            q.print "Uploaded to #{ofile}\n#{delmsg}"
        end
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
