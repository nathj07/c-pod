# The repositories used during Kickstart
# Note that these are not persisted after installation, for that
# use the post-install 'custom_repo' fragment

repo  --name=custom --baseurl="http://<!--#echo var=SERVER_ADDR -->/yum_repos/custom/6/stable/"
repo  --name=epel --baseurl="http://<!--#echo var=SERVER_ADDR -->/yum_repos/epel/6/"
