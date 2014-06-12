# Setup Ruby Gems
#

cat <<'GEMRC' > /etc/gemrc
gem: --no-document --clear-sources --source http://<!--#echo var="SERVER_NAME" -->/gem_repo/
GEMRC

gem install ruby-shadow
gem install bundler
