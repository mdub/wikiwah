#!/usr/bin/env ruby

require 'wikiwah/subst'
require 'test/unit'

module WikiWah

  class Subst_Tests < Test::Unit::TestCase
    
    def test_do_nothing
      subst = Subst.new
      assert_equal("xxx", subst.transform("xxx"))
    end
    
    def test_simple
      subst = Subst.new
      subst.add_transformation(/y/) { "Y" }
      assert_equal("xYz", subst.transform("xyz"))
    end
    
    def test_store
      subst = Subst.new
      subst.add_transformation(/x/) { "y" }
      subst.add_transformation(/y/) { "z" }
      assert_equal("yz", subst.transform("xy"))
    end
    
    def test_bold
      subst = Subst.new
      subst.add_transformation(/\*(\w+)\*/) { |match| "<b>#{match[1]}</b>" }
      assert_equal("a <b>b</b> c", subst.transform("a *b* c"))
    end
    
  end
  
end
