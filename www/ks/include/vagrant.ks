# Setup Vagrant user

# Set SSHD Config

ex /etc/ssh/sshd_config <<SSHD_NODNS
/UseDNS
.d
i
UseDNS no
.
x
SSHD_NODNS

# Setup sudo not to need password or tty

cat > /tmp/vagrant_sudo <<SUDO
# Vagrant
vagrant ALL=(ALL:ALL) NOPASSWD: ALL
Defaults:vagrant !requiretty
Defaults env_keep += "SSH_AUTH_SOCK"
SUDO
install -m 0600 /tmp/vagrant_sudo /etc/sudoers.d

# Add Vagrant key

cat > /tmp/vagrant_key <<SSHKEY
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
SSHKEY
install -d -m 0700 -o vagrant -g vagrant /home/vagrant/.ssh
install  -m 0600 -o vagrant -g vagrant /tmp/vagrant_key /home/vagrant/.ssh/authorized_keys
