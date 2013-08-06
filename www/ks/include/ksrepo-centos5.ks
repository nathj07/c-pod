# The repositories used during Kickstart
# Note that these are not persisted after installation, for that
# use the post-install 'custom_repo' fragment

repo  --name=custom --baseurl="http://<!--#echo var=SERVER_ADDR -->/yum_repos/custom/5/stable/"
repo  --name=epel --baseurl="http://<!--#echo var=SERVER_ADDR -->/yum_repos/epel/5/"

# Don't download and host the updates
# repo  --name=updates --baseurl="http://<!--#echo var=SERVER_ADDR -->/yum_repos/centos/5/updates/"
