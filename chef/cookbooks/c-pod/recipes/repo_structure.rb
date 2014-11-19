# Setup the filesystem structure for a C-Pod Repository webserver
#
base = node[:cpod][:base]
user = node[:cpod][:owner_name]

# Setup the YUM repository directories
#
%w{ yum_repos}.each do |a|
    directory File.join(base,a) do
        mode    02770
        owner   user
        group   user
    end
    %w{ lifted stable unstable }.each do |b|
        directory File.join(base,a,b) do
            mode    02770
            owner   user
            group   user
        end
        %w{ 5 6 7 }.each do |c|
            dir = File.join(base,a,b,c)
            directory dir do
                mode    02770
                owner   user
                group   user
            end
            link "#{dir}Server" do
                to        dir
                link_type :symbolic
            end
            %w{ noarch x86_64 }.each do |d|
                directory "#{dir}/#{d}" do
                    mode    02770
                    owner   user
                    group   user
                end
            end
        end
    end
end

# Setup the GEM repository directories
#
directory File.join(base,'gem_repo', 'gems') do
    action  :create
    mode    02770
    owner   user
    group   user
end

# Setup the other directories
#
%w{ cookbooks downloads osdisks isos }.each do |dir|
    directory File.join(node[:cpod][:base], dir) do
        action  :create
        mode    02770
        owner   node[:cpod][:owner_name]
        group   node[:cpod][:owner_name]
    end
end

=begin
execute "set ownership" do
    command "chown -R #{user}.#{user} #{base}"
end
execute "set group write" do
    command "chmod -R g+rw #{base}/*"
end
execute "set sticky on yum_repos" do
    command "find #{base}/yum_repos -type d -exec chmod 2770 {} \\;"
end
execute "set u=rw,g=rw on yum_repos" do
    command "find #{base}/yum_repos -type f -exec chmod 660 {} \\;"
end
=end
# vim: sts=4 sw=4 ts=8
