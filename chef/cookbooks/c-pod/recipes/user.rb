# Setting up a C-Pod user
# Note use of setgid and c-pod group to allow sharing
# Together with umask 0002
#
cpod_user = node[:cpod][:owner_name] or 'c-pod'

basedir=node[:cpod][:base] or "/home/#{cpod_user}"

group cpod_user do
  action :create
end

user cpod_user do
  action    :create
  comment   "C-Pod owner"
  supports :manage_home => false
end

directory basedir do
    owner cpod_user
    group cpod_user
    mode 02755 # Don't make group writeable as stops ssh keys working
end

cookbook_file "#{basedir}/README" do
    source  'README.data'
    mode    0644
    owner   cpod_user
    group   cpod_user
end

# vim: sts=4 sw=4 ts=8
