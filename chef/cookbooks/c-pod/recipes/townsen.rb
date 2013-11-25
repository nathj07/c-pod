# A Recipe to setup Nick T.
#
group 'townsen' do
    action :create
    gid 625
end

homedir =  '/home/townsen'

user 'townsen' do
    action :create
    comment "Nick Townsend"
    home    homedir
    gid 625
    uid 625
    password '$1$ZjqgZlNs$mIqvBcMq6kcUCDsLjyH3I0'
    supports :manage_home => true
end

cookbook_file "#{homedir}/.vimrc" do
    source  'townsen.vimrc'
    mode    0644
    owner   'townsen'
    group   'townsen'
end

directory "#{homedir}/.vim" do
    mode    0755
    owner   'townsen'
    group   'townsen'
end
directory "#{homedir}/.vim/autoload" do
    mode    0755
    owner   'townsen'
    group   'townsen'
end
directory "#{homedir}/.vim/bundle" do
    mode    0755
    owner   'townsen'
    group   'townsen'
end

remote_file "#{homedir}/.vim/autoload/pathogen.vim" do
  source "https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim"
end

%w{ vim-fugitive vim-rails vim-bundler }.each do |ext|
    git "#{homedir}/.vim/bundle/#{ext}" do
	repository "git://github.com/tpope/#{ext}.git"
	reference "master"
	action :sync
    end
end

template "#{homedir}/.rpmmacros" do
    action  :create
    source  'rpmmacros.erb'
    mode    0644
    owner   'townsen'
    group   'townsen'
    variables( 
	:homedir => homedir
    )
end

template "#{homedir}/.gitconfig" do
    action  :create
    source  'gitconfig.erb'
    mode    0644
    owner   'townsen'
    group   'townsen'
    variables( 
	:useremail => 'nick.townsend@mac.com', :usergecos => 'Nick Townsend' 
    )
end

cookbook_file "#{homedir}/.inputrc" do
    source  'townsen.inputrc'
    mode    0644
    owner   'townsen'
    group   'townsen'
end

directory "#{homedir}/.ssh" do
    owner   'townsen'
    group   'townsen'
    mode    0750
end

cookbook_file "#{homedir}/.ssh/config" do
    action  :create_if_missing
    source  'config.ssh'
    mode    0644
    owner   'townsen'
    group   'townsen'
end

cookbook_file "#{homedir}/.ssh/authorized_keys" do
    source  'townsen.pub'
    mode    0644
    owner   'townsen'
    group   'townsen'
end

directory "/root/.ssh" do
    mode    0700
    owner   'root'
    group   'root'
end

cookbook_file "/root/.ssh/authorized_keys" do
    source  'townsen.pub'
    mode    0644
end

user_ulimit "townsen" do
  filehandle_limit 8192
end

# vim: sts=4 sw=4 ts=8 et
