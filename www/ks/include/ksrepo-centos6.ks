# The repositories used during Kickstart
# Note that these are not persisted after installation, for that
# use the post-install 'custom_repo' fragment

repo  --name=custom --baseurl="http://<!--#echo var=SERVER_ADDR -->/repos/custom/6/stable/"
repo  --name=epel --baseurl="http://<!--#echo var=SERVER_ADDR -->/repos/epel/6/"
# Don't download and host the updates
# repo  --name=updates --baseurl="http://<!--#echo var=SERVER_ADDR -->/repos/centos/6/updates/"
