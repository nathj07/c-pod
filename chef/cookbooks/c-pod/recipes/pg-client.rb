# A Recipe to setup PostgreSQL client
#
yum_package 'postgresql92-devel'
# The -devel package (used to compile ruby-pg) installs the following as dependencies:
# yum_package 'postgresql92-libs'
# yum_package 'postgresql92-devel'

template "/etc/profile.d/postgres.sh" do
    mode        0644
    source      'postgres.sh.erb'
    variables(  :version => '9.2' )
end

# vim: sts=4 sw=4 ts=8
