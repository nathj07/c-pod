# Setup the filesystem structure for a C-Pod Repository webserver
#
datadir = node[:cpod][:datadir]
basedir = node[:cpod][:base]
user = node[:cpod][:owner_name]

# Setup the YUM repository directories
#
%w{ yum_repos}.each do |a|
    directory File.join(datadir,a) do
        mode    02770
        owner   user
        group   user
    end
    %w{ lifted stable unstable }.each do |b|
        directory File.join(datadir,a,b) do
            mode    02770
            owner   user
            group   user
        end
        %w{ 5 6 7 }.each do |c|
            dir = File.join(datadir,a,b,c)
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
directory File.join(datadir,'gem_repo') do
    action  :create
    mode    02770
    owner   user
    group   user
end

directory File.join(datadir,'gem_repo', 'gems') do
    action  :create
    mode    02770
    owner   user
    group   user
end

# Setup the other directories
#
%w{ cookbooks downloads osmirror }.each do |dir|
    directory File.join(node[:cpod][:datadir], dir) do
        action  :create
        mode    02770
        owner   node[:cpod][:owner_name]
        group   node[:cpod][:owner_name]
    end
end

# Setup the links
#
%w{ downloads gem_repo isos osmirror yum_repos }.each do |dir|
    link "#{basedir}/c-pod/www/#{dir}" do
        to  "#{datadir}/#{dir}"
    end
end
link "#{basedir}/c-pod/www/gems" do
    to  "#{datadir}/gem_repo/gems"
end

# vim: sts=4 sw=4 ts=8
