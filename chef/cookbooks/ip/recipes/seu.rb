# Library dependencies for SEU
# (wip)
#
validate_platform

# Illustrate two ways of varying based on OS version
# Both functions defined in the default.rb library
#

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
