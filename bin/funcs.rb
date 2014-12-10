# Common functions for C-Pod binaries
#
# Parses name, version etc from a package name
#
def parsepkg package, force_rhel = nil
    raise "Can't parse package name '#{package}'" unless /(?<pkgname>^.*?)-(?<ver>[0-9\.]*\d)[.-](?<pkginfo>.*)$/ =~ package

    info = { name: pkgname, version: ver }
    pkgparts = pkginfo.split /[.-]/
    case info[:format] = pkgparts.pop
    when 'rpm'
        info[:arch] = pkgparts.pop
        raise "Architecture '#{info[:arch]}' is not supported" unless ['x86_64','noarch'].include? info[:arch]
        if pkgparts.detect { |c| /^(?:rh)?el(\d)(_.*)?$/ =~ c }
            info[:rhel] = $~[1]
        else
            raise "Can't determine CentOS release for '#{package}'. Force with -c option" unless force_rhel
            info[:rhel] = force_rhel
        end
    when 'gem'
    else
        raise "Suffix #{info[:format]} is not a recognized package type"
    end
    return info
end

# vim: sts=4 sw=4 ts=8
