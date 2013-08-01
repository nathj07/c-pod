# The repositories used during Kickstart
# Note that these are not persisted after installation, for that
# use the post-install 'sye_repo' fragment

repo  --name=sye_repo --baseurl="http://<!--#echo var=SERVER_ADDR -->/repos/sye/6/stable/"
repo  --name=updates --baseurl="http://<!--#echo var=SERVER_ADDR -->/repos/centos/6/updates/"
