# Apache recipe
#
yum_package 'httpd'
gem_package 'redcarpet' do # for markdown
    options "--no-rdoc --no-ri"
end

service 'httpd' do
    supports :restart => true, :reload => true
    action :enable
end

# vim: sts=4 sw=4 ts=8
