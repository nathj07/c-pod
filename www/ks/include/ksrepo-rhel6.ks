# The repositories used during Kickstart
# Note that these are not persisted after installation, for that
# use the post-install 'strepo' fragment

repo  --name=strepo --baseurl="http://<!--#echo var=SERVER_ADDR -->/repos/sye/6Server/stable/"
repo  --name=updates --baseurl="http://<!--#echo var=SERVER_ADDR -->/repos/rhel/6Server/updates/"
