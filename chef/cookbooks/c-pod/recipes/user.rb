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
  password 'c-pod' unless node[:cpod][:ssh_key]
  supports :manage_home => false
end

directory basedir do
    owner cpod_user
    group cpod_user
    # Permissions:
    # * Don't make group writeable as stops ssh keys working
    # * setgid so that all subdirs are created in the same group
    mode 02755
end

cookbook_file "#{basedir}/README" do
    source  'README.data'
    mode    0644
    owner   cpod_user
    group   cpod_user
end

template "#{basedir}/.gitconfig" do
    action  :create
    source  'gitconfig.erb'
    mode    0664
    owner   cpod_user
    group   cpod_user
    variables(
        :useremail => 'c-pod@sendium.net', :usergecos => 'C-Pod User'
    )
end

directory "#{basedir}/.ssh" do
    owner cpod_user
    group cpod_user
    mode 0750
end

file "#{basedir}/.ssh/authorized_keys" do
    action  :create_if_missing
    only_if { node[:cpod][:ssh_key] }
    content node[:cpod][:ssh_key]
    mode    0644
    owner   cpod_user
    group   cpod_user
end

# vim: sts=4 sw=4 ts=8
