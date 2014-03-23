# A Recipe to setup a minimal developer toolset for building Ruby GEMs
# Use this instead of the YUM groups:
# @Additional Development
# @Development
# This is equivalent to the pkgs_mindev.ks Kickstart fragment
#
%w{
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
}.each { |pkg| yum_package pkg }

case osver
when 5...6
    yum_package 'libyaml'
when 6...7
    yum_package 'libyaml-devel'
end

# vim: sts=4 sw=4 ts=8
