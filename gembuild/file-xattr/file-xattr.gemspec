Gem::Specification.new do |s|
  s.name = %q{file-xattr}
  s.version = "0.62"
  s.required_ruby_version = ">=1.9.2"
  s.date = %q{2010-10-19}
  s.authors = ['Nick Townsend']
  s.email = ['nick.townsend@mac.com']
  s.summary = %q{File based Interface to Extended Attributes}
  s.homepage = %q{http://theinternetco.net/projects/ruby/ruby-xattr-0.3.0.tar.gz}
  s.has_rdoc = true
  s.extra_rdoc_files = ['TODO.txt','USAGE.txt']
  s.files = [ "extconf.rb", "ext/xattr.c", "tests/test.rb", "tests/limits.rb" ]
  s.require_path =  '.'
  s.test_files = [ "tests/test.rb", "tests/limits.rb" ]
  s.extensions = 'extconf.rb'
  s.description = "Interface to Extended attributes which extends the Ruby File object rather than introducing a new Xattr object typ. Extensively modified version of a work by Ariridel. Portable between Mac OS X and RHEL 5.4+."
end
