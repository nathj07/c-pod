# Puppet, Facter and Augeas are installed as GEMs in %post phase
# these are the binary prerequisites for them and building GEMs
gcc-c++
gcc
make
libtool-ltdl
libtool-ltdl-devel
augeas
augeas-libs
augeas-devel
# We install the default Ruby at kickstart time.
# Our own version of Ruby (Enterprise Ruby) is installed by Puppet
ruby
ruby-irb
ruby-libs
ruby-rdoc
ruby-devel
rubygems
