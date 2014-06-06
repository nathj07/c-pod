# Apache recipe
# We include mod_ssl but remove the config file as it contains
# a default virtual host, which we want to configure elsewhere
#
yum_package 'httpd'
yum_package 'mod_ssl'

cookbook_file '/etc/httpd/conf.d/ssl.conf' do
    action  :create
    mode    0644
    owner   'root'
    group   'root'
end

service 'httpd' do
    supports :restart => true, :reload => true
    action :enable
end

# vim: sts=4 sw=4 ts=8
