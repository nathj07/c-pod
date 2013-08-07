# Default recipe just puts footprint...
#
template '/etc/REPOCONF' do
    action :create
    user "root"
    group "root"
end

# vim: sts=4 sw=4 ts=8
