# Passenger recipe
#
# TODO: When running this the `gem which phusion_passenger` is run at recipe compile
# time prior to the gem install. This shows an error but is benign as it works
#
include_recipe 'c-pod::apache'
include_recipe 'c-pod::devtools'

yum_package 'curl-devel'
yum_package 'apr-devel'
yum_package 'httpd-devel'

gem_package 'passenger' do
    version "4.0.46"
    options "--no-rdoc --no-ri"
    notifies :run, "execute[passenger-install]", :immediately
end

execute 'passenger-install' do
    action  :nothing
    command "passenger-install-apache2-module --auto"
    notifies :create, "template[/etc/httpd/conf.d/_passenger.conf]", :immediately
end

template "/etc/httpd/conf.d/_passenger.conf" do
    action  :create
    mode    0644
    owner   'apache'
    group   'apache'
    variables lazy {
        /EXECUTABLE:\s*(?<binary>\S+)/m =~ `gem environment`
        base = File.absolute_path('..', File.dirname(`gem which phusion_passenger`))
        { :base => base, :ruby => binary }
    }
    notifies :restart, "service[httpd]", :delayed
end

# vim: sts=4 sw=4 ts=8
