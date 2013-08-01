# Setup Puppet

groupadd -r puppet
useradd -c "Puppet" -d /etc/puppet -g puppet -r puppet
mkdir /etc/puppet

# Configure RubyGems and Gems for Puppet

/usr/local/bin/gem install rubygems-update -v 1.6.2
/usr/local/bin/gem update_rubygems
/usr/local/bin/gem install puppet -v 2.7.1
/usr/local/bin/gem install facter -v 1.6.0
/usr/local/bin/gem install ruby-augeas -v 0.4.1

cat <<-'PUPPETCONF' > /etc/puppet/puppet.conf
[main]
# Default to test environment, change to 'stable' for production
environment=unstable
pluginsync = true
factpath = $vardir/lib/facter
# vim: ts=8 sw=4 sts=4
PUPPETCONF

cat <<AUTH > /etc/puppet/auth.conf
path /run
method save
allow *
AUTH

cat <<NAMESPACEAUTH > /etc/puppet/namespaceauth.conf
[kick]
allow puppet
NAMESPACEAUTH

chown -R puppet.puppet /etc/puppet
