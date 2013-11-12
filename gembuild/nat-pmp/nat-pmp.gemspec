Gem::Specification.new do |s|
  s.name = %q{nat-pmp}
  s.version = "0.40"
  s.required_ruby_version = ">=1.9.2"
  s.date = %q{2013-11-11}
  s.authors = ['Nick Townsend']
  s.email = ['nick.townsend@mac.com']
  s.summary = %q{Encapsulate NAT-PMP protocol}
  s.homepage = %q{https://github.com/townsen/c-pod/}
  s.has_rdoc = false
  s.files = [ "lib/nat-pmp.rb", "bin/nat-pmp" ]
  s.test_files = [ "test/test_nat-pmp.rb" ]
  s.description = "Interface to NAT-PMP. Portable between Mac OS X and RHEL 5.4+."
  s.executables << "nat-pmp"
end
