# Setup Puppet
# Everything now runs as root

# Configure RubyGems and Gems for Puppet

gem install rubygems-update -v 1.6.2
update_rubygems _1.6.2_
gem install puppet -v 2.7.1
gem install facter -v 1.6.0
gem install ruby-augeas -v 0.4.1

mkdir /etc/puppet

cat <<-'PUPPETCONF' > /etc/puppet/puppet.conf
[main]
# Default to test environment, change to 'stable' for production
environment=unstable
pluginsync = true
factpath = $vardir/lib/facter
# vim: ts=8 sw=4 sts=4
PUPPETCONF
