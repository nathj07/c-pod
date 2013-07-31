require 'xattr'
require 'test/unit'

# Basic function testing. See limits.rb for more sophistication

class TestXAttrs < Test::Unit::TestCase
    @@attrname = "user.description"
    @@filename = "xattr_test.file"

    def setup
	f = File.open(@@filename, 'w')
	f.puts("Some test data")
	f.close
    end

    def teardown
	File.unlink(@@filename)
    end

    def test_1
	File.set_attr(@@filename, @@attrname, 'Test 1')
	assert_equal("Test 1", File.get_attr(@@filename, @@attrname))
    end

    def test_2
	File.set_attr(@@filename, @@attrname, 'Test 2')
	File.open(@@filename, 'r') do |f|
	    assert_equal("Test 2", f.get_attr(@@attrname))
	end
    end

    def test_3
	File.set_attr(@@filename, @@attrname, 'Test 3')
	assert_equal(File.get_all_attrs(@@filename)[@@attrname], "Test 3")
    end

    def test_4
	File.set_attr(@@filename, @@attrname, 'Test 4')
	File.open(@@filename, 'r') do |f|
	    assert_equal(f.get_all_attrs[@@attrname], "Test 4")
	end
    end
end

# vim: set ts=8 sw=4 sts=4:
