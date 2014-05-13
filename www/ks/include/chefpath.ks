# Setup the system path to include chef.
# The Opscode RPM doesn't do this on CentOS 5.9
#
cat > /etc/profile.d/chef.sh <<CHEFPATH
# Setup the system path to include chef.
# The Opscode RPM doesn't do this on CentOS 5.9
pathmunge /opt/chef/bin
CHEFPATH
