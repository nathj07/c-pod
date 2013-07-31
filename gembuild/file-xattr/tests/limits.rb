#!/usr/bin/ruby  -rrubygems
#
# Capacity tests for EA
#
require 'xattr'

file= ARGV.size > 0 ? ARGV[0] : 'xattr_test.file'

$stdout.puts "Testing on file #{file}"

nsizes = [32, 63, 64, 100, 127, 128, 250, 255, 256, 511, 512]
vsizes = [511, 512, 1000, 1023, 1024, 2047, 2048, 3000, 4000, 4095, 4096, 65000, 65535, 65536, 100000]

f = File.open(file, File.exist?(file) ? 'r': 'w')

f.list_attrs.each { |at| f.remove_attr(at) }

begin
  $stdout.print "Can we write an EA without the 'user.' prefix? "
  f.set_attr("mission", "moon")
  $stdout.puts "YES"
rescue
  $stdout.puts "NO"
end

begin
  $stdout.print "Can we write one with it? "
  f.set_attr("user.mission", "moon")
  $stdout.puts "YES"
rescue
  $stdout.puts "NO"
end

begin
  $stdout.print "Can we use uppercase names? "
  f.set_attr("user.Mission", "moon")
  $stdout.puts "YES"
rescue
  $stdout.puts "NO"
end

begin
  $stdout.print "How big can we make the name?"
  nsizes.each { |s| 
    $stdout.print " #{s}="
    name = "user."+("z" * (s-5))
    f.set_attr(name, "t")
    $stdout.print "YES"
  }
rescue
  $stdout.puts "NO"
end

f.list_attrs.each { |at| f.remove_attr(at) }

begin
  $stdout.print "How big can we make a single value?"
  vsizes.each { |s| 
    $stdout.print " #{s}="
    f.set_attr("user.t", "z" * s)
    $stdout.print "YES"
  }
rescue
  $stdout.puts "NO"
end

f.list_attrs.each { |at| f.remove_attr(at) }

begin
  $stdout.print "What is the upper limit on all the values?"
  total = 0
  vsizes.each { |s| 
    total += s
    $stdout.print " #{total}="
    f.set_attr("user.#{s}", "z" * s)
    $stdout.print "YES"
  }
rescue
  $stdout.puts "NO"
end
$stdout.puts ""
