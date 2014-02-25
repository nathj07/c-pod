# This fragment specifies the bare minimum packages for a production machine
#
# The grouplist could possibly be pared down TODO

@Base
@Console internet tools
@System administration tools
#@Compatibility libraries
@Hardware monitoring utilities
@Networking Tools
@Performance Tools
@Perl Support

# Require at package level (to be sure)

yum-plugin-priorities
avahi
nss-mdns
git
ruby
