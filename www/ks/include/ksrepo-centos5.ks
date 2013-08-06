# The repositories used during Kickstart
# Note that these are not persisted after installation, for that
# use the post-install 'custom_repo' fragment

repo  --name=custom --baseurl="http://<!--#echo var=SERVER_ADDR -->/yum_repos/custom/5/stable/"
repo  --name=lifted --baseurl="http://<!--#echo var=SERVER_ADDR -->/yum_repos/lifted/5/"
