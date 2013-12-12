# Simple tests
# Only work if the network gateway has NAT-PMP
# TODO Mock out the gateway object
#
require 'test/unit'
require 'natpmp'

class TestNATPMP < Test::Unit::TestCase
  def test_gw
    gw = NATPMP.GW
    assert_match(/^(\d{1,3}\.){3}\d{1,3}$/, gw, "Return IPv4 address")
  end
  def test_basic
    map = NATPMP.map 633, 13033, 30, :tcp
    assert_equal(633, map.priv)
    assert_equal(13033, map.pub)
    assert_equal(30, map.life)
    assert_equal(:tcp, map.type)
  end
  def test_block
    m = NATPMP.map 633, 13033, 10, :tcp do |map|
      assert_equal(NATPMP::DEFAULT_LIFETIME, map.life)
    end
    assert_nil(m)
  end
end
