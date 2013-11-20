# Passenger recipe
#
include_recipe 'c-pod::apache'

gem_package 'passenger' do
    options "--no-rdoc --no-ri"
    notifies :run, "execute[passenger-install]", :immediate
end

yum_package 'curl-devel'
yum_package 'apr-devel'
yum_package 'httpd-devel'

execute 'passenger-install' do
    creates "/etc/httpd/conf.d/_passenger.conf"
    command "passenger-install-apache2-module --auto"
end

/EXECUTABLE:\s*(?<binary>\S+)/m =~ `gem environment`

template "/etc/httpd/conf.d/_passenger.conf" do
    action  :create
    mode    0644
    owner   'apache'
    group   'apache'
    variables( :base => File.absolute_path('..', File.dirname(`gem which phusion_passenger`)), :ruby => binary)
    notifies :restart, "service[httpd]", :delayed
end

# vim: sts=4 sw=4 ts=8
