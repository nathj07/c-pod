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
# We install our own version of Ruby (Enterprise Ruby) as no standard 1.8.7 exists for EL5
ruby-enterprise
ruby-enterprise-rubygems
ruby-enterprise-shadow
