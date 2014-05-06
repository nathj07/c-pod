# Setting up a C-Pod user
# Note use of setgid and c-pod group to allow sharing
# Together with umask 0002
#
node.default[:cpod][:base] = '/data'
node.default[:cpod][:owner_name] = 'c-pod'
node.default[:cpod][:owner_id] = 606
node.default[:cpod][:github_key] = 'townsen' # User to give public key access

cpod_user = node[:cpod][:owner_name]

BASE=node[:cpod][:base]

group cpod_user do
  action :create
  gid node[:cpod][:owner_id]
  members 'apache'
  append true
end

user cpod_user do
  action    :create
  comment   "C-Pod owner"
  home	    BASE
  gid node[:cpod][:owner_id]
  uid node[:cpod][:owner_id]
  supports :manage_home => false
end

directory BASE do
    owner cpod_user
    group cpod_user
    # Permissions:
    # * Don't make group writeable as stops ssh keys working
    # * setgid so that all subdirs are created in the apache group
    mode 02755
end

cookbook_file "#{BASE}/README" do
    source  'README.data'
    mode    0644
    owner   cpod_user
    group   cpod_user
end

template "#{BASE}/.gitconfig" do
    action  :create
    source  'gitconfig.erb'
    mode    0664
    owner   cpod_user
    group   cpod_user
    variables(
        :useremail => 'c-pod@sendium.net', :usergecos => 'C-Pod User'
    )
end

directory "#{BASE}/.ssh" do
    owner cpod_user
    group cpod_user
    mode 0750
end

remote_file "#{BASE}/.ssh/authorized_keys" do
    action  :create_if_missing
    source "https://github.com/#{node[:cpod][:github_key]}.keys"
    mode    0644
    owner   cpod_user
    group   cpod_user
end

# vim: sts=4 sw=4 ts=8
