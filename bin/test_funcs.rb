#!/usr/bin/env ruby
#
# Test utilities
#
require 'minitest/autorun'

require_relative 'funcs'

describe "parsepkg" do
    describe "recognizes" do
        it "a simple GEM" do
            pkg = "passenger-4.0.42.gem"
            pkginfo = parsepkg pkg
            pkginfo[:format].must_equal 'gem'
            pkginfo[:name].must_equal 'passenger'
            pkginfo[:version].must_equal '4.0.42'
        end
        it "a simple RPM" do
            pkg = "redis-2.8.9-0.el6.x86_64.rpm"
            pkginfo = parsepkg pkg
            pkginfo[:format].must_equal 'rpm'
            pkginfo[:name].must_equal 'redis'
            pkginfo[:version].must_equal '2.8.9'
            pkginfo[:arch].must_equal 'x86_64'
            pkginfo[:rhel].must_equal '6'
        end
        it "an architecture dependent GEM" do
            pkg = "json-1.7.7-x86_64-linux.gem"
            pkginfo = parsepkg pkg
            pkginfo[:format].must_equal 'gem'
            pkginfo[:name].must_equal 'json'
            pkginfo[:version].must_equal '1.7.7'
        end
        it "a GEM with underscore name" do
            pkg = "daemon_controller-1.2.0.gem"
            pkginfo = parsepkg pkg
            pkginfo[:format].must_equal 'gem'
            pkginfo[:name].must_equal 'daemon_controller'
            pkginfo[:version].must_equal '1.2.0'
        end
        it "an RPM with single digit version" do
            pkg = "seu-3cb59bc-extra-1-0.el6.x86_64.rpm"
            pkginfo = parsepkg pkg
            pkginfo[:format].must_equal 'rpm'
            pkginfo[:name].must_equal 'seu-3cb59bc-extra'
            pkginfo[:version].must_equal '1'
            pkginfo[:arch].must_equal 'x86_64'
            pkginfo[:rhel].must_equal '6'
        end
        it "a noarch RPM" do
            pkg = "epel-release-6-8.noarch.rpm"
            pkginfo = parsepkg pkg
            pkginfo[:format].must_equal 'rpm'
            pkginfo[:name].must_equal 'epel-release'
            pkginfo[:version].must_equal '6'
            pkginfo[:arch].must_equal 'noarch'
            pkginfo[:rhel].must_equal '6'
        end
        it "an RPM with minus separators" do
            pkg = "splunk-6.1.1-207789-linux-2.6-x86_64.rpm"
            pkginfo = parsepkg pkg
            pkginfo[:format].must_equal 'rpm'
            pkginfo[:name].must_equal 'splunk'
            pkginfo[:version].must_equal '6.1.1'
            pkginfo[:arch].must_equal 'x86_64'
            pkginfo[:rhel].must_equal '6' # defaulted
        end
    end
    describe "refuses to parse" do
        it "a piece of junk" do
            pkg = "splunk.tgz"
            proc {
                pkginfo = parsepkg pkg
            }.must_raise RuntimeError
        end
        it "a SRPM" do
            pkg = "bacula-5.0.0-12.el6.src.rpm"
            proc {
                pkginfo = parsepkg pkg
            }.must_raise RuntimeError
        end
    end
end
        
# vim: sts=4 sw=4 ts=8
