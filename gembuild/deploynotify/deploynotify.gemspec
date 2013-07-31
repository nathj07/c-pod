# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "deploynotify/version"

Gem::Specification.new do |s|
  s.name        = "deploynotify"
  s.version     = Deploynotify::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Peter Hulst"]
  s.email       = ["phulst@blurb.com"]
  s.homepage    = ""
  s.summary     = %q{Deployment notification gem}
  s.description = %q{This gem hosts functionality for sending out deployment notifications by emai, and automatically updating Pivotal Tracker, Bugzilla and Jira based on information from Git commits}

#  s.rubyforge_project = "deploynotify"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  # s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency('rspec')
  
  s.add_dependency('grit', '>= 2.3.0')
  s.add_dependency('pivotal-tracker', '>= 0.2.2')
  s.add_dependency('pony', '>= 1.0.1')
  s.add_dependency('jira4r', '>= 0.3.0')

end
