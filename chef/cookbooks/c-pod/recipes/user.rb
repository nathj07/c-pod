# Setting up the C-Pod user
#
cpod_user = node[:cpod][:owner_name] or 'c-pod'

group cpod_user do
  action :create
end

user cpod_user do
  action    :create
  comment   "C-Pod owner"
  supports  :manage_home => false
  gid       cpod_user
end

# vim: sts=4 sw=4 ts=8
