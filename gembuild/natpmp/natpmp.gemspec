Gem::Specification.new do |s|
  s.name = %q{natpmp}
  s.version = "0.61"
  s.required_ruby_version = ">=1.9.2"
  s.date = %q{2013-11-11}
  s.authors = ['Nick Townsend']
  s.email = ['nick.townsend@mac.com']
  s.summary = %q{Encapsulate NAT-PMP protocol}
  s.homepage = %q{https://github.com/townsen/c-pod/}
  s.has_rdoc = false
  s.files = [ "lib/natpmp.rb", "bin/natpmp" ]
  s.test_files = [ "test/test_natpmp.rb" ]
  s.description = "Interface to NAT-PMP. Portable between Mac OS X and CentOS 5+."
  s.executables << "natpmp"
end
