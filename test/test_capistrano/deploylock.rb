require 'minitest_helper'

class TestCapistrano::Deploylock < MiniTest::Unit::TestCase
  def test_that_it_has_a_version_number
    refute_nil ::Capistrano::Deploylock::VERSION
    assert !defined?(Thin)
  end

  def test_it_does_something_useful
    assert true
  end
end
