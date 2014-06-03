# Common functions for C-Pod binaries
#
# Parses name, version etc from a package name
#
def parsepkg package
    raise "Can't parse package name '#{package}'" unless /(?<pkgname>^.*?)-(?<ver>[0-9\.]*\d)[.-](?<pkginfo>.*)$/ =~ package

    info = { name: pkgname, version: ver }
    pkgparts = pkginfo.split /[.-]/
    info[:format] = pkgparts.pop
    case info[:format]
    when 'rpm'
	info[:arch] = pkgparts.pop
        raise "Architecture '#{info[:arch]}' is not supported" unless ['x86_64','noarch'].include? info[:arch]
	info[:rhel] = if pkgparts.select { |c| c =~ /^(rh)?el5(_.*)?$/ }.size > 0
		   '5'
	       elsif pkgparts.select { |c| c =~ /^(rh)?el6(_.*)?/ }.size > 0
		   '6'
	       else
		   '6' # put unlabelled ones in 5
	       end
    when 'gem'
    else
        raise "Suffix #{suffix} is not a recognized package type"
    end
    return info
end

# vim: sts=4 sw=4 ts=8
