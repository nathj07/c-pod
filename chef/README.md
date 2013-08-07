Using Chef-Solo
===============

A demo of using chef-solo. First install it:

    gem install chef

Run using the command: `chef-solo -c solo.rb -j solo.json`

See https://github.com/opscode-cookbooks for more cookbooks

Gotchas
-------
As of chef 11.6.0
* When using a remote cookbook, the cookbook_path _must_ end with `/cookbooks`
* The remote cookbook must be a tgz file beginning with `cookbooks/`
