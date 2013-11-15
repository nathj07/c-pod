# -*- encoding: utf-8 -*-
# Modifed gemspec to use after installation to create a binary gem

Gem::Specification.new do |spec|
  spec.authors               = ['Adam Palmblad',
                                'Eric Hankins',
                                'Ian Marlier',
                                'Jeff Blaine',
                                'Remi Broemeling',
                                'Takaaki Tateishi',
                                'Nick Townsend']

  spec.description           = 'This module provides access to shadow passwords on Linux and Solaris'
  spec.email                 = ['adam.palmblad@teampages.com']
  spec.platform              = Gem::Platform::CURRENT
  spec.files                 = %w{
    ./README.euc
    ./README
    ./MANIFEST
    ./ruby-shadow.gemspec
    ./HISTORY
    ./lib
    ./lib/shadow.so
    }
  spec.homepage              = 'https://github.com/apalmblad/ruby-shadow'
  spec.name                  = 'ruby-shadow'
  spec.required_ruby_version = ['>= 2.0']
  spec.require_paths	     = ["lib"]
  spec.summary               = '*nix Shadow Password Module'
  spec.version               = '2.2.0'
  spec.license  = "Public Domain License"
end
