#!/usr/bin/env ruby

require 'wikiwah'
require 'test/unit'

class WikiWahTests < Test::Unit::TestCase

  def assert_wikiwah(expected, input)
    assert_equal(expected, Wikiwah.convert(input))
  end

  def test_empty
    assert_wikiwah("", "")
  end

  def test_paragraph
    assert_wikiwah("<p>\nxyz\n</p>\n", "xyz\n")
  end
  
  def test_strong
    assert_wikiwah("<p>\n<strong>xyz</strong>\n</p>\n", "*xyz*\n")
  end
  
  def test_em
    assert_wikiwah("<p>\n<em>xyz</em>\n</p>\n", "/xyz/\n")
  end
  
  def test_strong_em
    assert_wikiwah("<p>\n<strong><em>xyz</em></strong>\n</p>\n", "*/xyz/*\n")
  end
  
  def test_strong_then_em
    assert_wikiwah("<p>\n<strong>abc</strong>=<em>xyz</em>\n</p>\n", "*abc*=/xyz/\n")
  end
  
  def test_link
    assert_wikiwah(%{<p>\n<a href='/yyy'>xxx</a>\n</p>\n}, 
                   "{xxx}@/yyy\n")
  end
  
  def test_bold_link
    assert_wikiwah(%{<p>\n<a href='/yyy'><strong>xxx</strong></a>\n</p>\n}, 
                   "{*xxx*}@/yyy\n")
  end
  
  def assert_wikiwah_unchanged(input)
    expected = "<p>\n" + input + "</p>\n"
    assert_wikiwah(expected, input)
  end

  def test_inline_html
    assert_wikiwah_unchanged(%{<b>blah</b><img src="xxx" />})
  end
  
  def test_inline_html_with_link
    assert_wikiwah_unchanged(%{<b>blah</b><img src="http://blah.com" />})
  end
  
end
