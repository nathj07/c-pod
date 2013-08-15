# Library dependencies for SEU
# (wip)
#
validate_platform

yum_package 'zlib-devel'
yum_package 'glib2-devel'
yum_package 'fontconfig'
yum_package 'freetype-devel'
yum_package 'postgresql-libs'
yum_package 'mysql-devel'
yum_package 'sqlite-devel'
yum_package 'uriparser-devel'
yum_package 'protobuf-devel'
yum_package 'protobuf-static'
yum_package 'GraphicsMagick-c++-devel'
yum_package 'xsd'
yum_package 'libmemcached-devel'
yum_package 'antiword'
yum_package 'lynx'
yum_package 'libwpd-tools'
yum_package 'odt2txt'
yum_package 'libxml2-devel'
yum_package "log4cpp-devel == 1.0-13ip#{dist}"

yum_package 'sparsehash-devel == 1.12'
yum_package 'ekhtml-devel == 0.3.2'
yum_package 'yaml-cpp-devel == 0.3.0'
yum_package 'yajl-devel == 1.0.9'
yum_package 'adns-devel == 1.2'

case osver
when 5...6
    yum_package 'expat == 1.95.8'
when 6...7
    yum_package 'expat == 2.0.1'
end

# The selectors can be a range, regex a string or a number
#
yum_package value_for_version(
    5.4..5.9 => 'libxml2 == 2.6.26',
    /^6\./ => 'libxml2 == 2.7.6' 
)

# vim: sts=4 sw=4 ts=8
