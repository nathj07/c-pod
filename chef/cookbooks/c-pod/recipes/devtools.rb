# A Recipe to setup a minimal developer toolset for building Ruby GEMs
# Use this instead of the YUM groups:
# @Additional Development
# @Development
# This is equivalent to the pkgs_mindev.ks Kickstart fragment
#
case node[:platform_family]
when 'rhel'
    packages = %w{
	gcc-c++
	gcc
	make
	patch
	readline
	readline-devel
	zlib
	zlib-devel
	openssl-devel
	libtool-ltdl
	libtool-ltdl-devel
	man-pages
    }
    case osver
    when 5...6
	packages << 'libyaml'
    when 6...7
	packages << 'libyaml-devel'
    end

when 'debian'
    packages = %w{
	g++
	gcc
	make
	patch
	libreadline-dev
	zlib1g-dev
	libltdl-dev
	libyaml-dev
    }

when 'mac_os_x'
    error "Not supported yet!"

end

packages.each { |pkg| package pkg }

# vim: sts=4 sw=4 ts=8
