require 'mkmf'

if (RUBY_PLATFORM =~ /darwin/ and have_library('System', 'setxattr')) 
then
  $CPPFLAGS << " -DDARWIN"
  create_makefile('xattr', 'ext')
elsif (RUBY_PLATFORM =~ /linux/ and have_library('attr', 'setxattr')) 
  $CPPFLAGS << " -DLINUX"
  create_makefile('xattr', 'ext')
else
  puts "Can't find Extended Attribute functions on platform: #{RUBY_PLATFORM}" 
  puts "If you are on RHEL you probably need libattr-devel" 
  puts "If you are on MacOS X you probably need Xcode and the Unix tools" 
end
