require File.dirname(__FILE__) + '/test_helper'
require 'marker'

class FormattingTest < Test::Unit::TestCase

  def test_bold_formatting
    text = "'''bold'''"
    markup = Marker.parse text
    
    assert_match("<b>bold</b>", markup.to_html)
  end

  def test_italic_formatting
    text = "''italic''"
    markup = Marker.parse text
    
    assert_match("<i>italic</i>", markup.to_html)
  end

  def test_bold_italic_formatting
    text = "'''''bold & italic'''''"
    markup = Marker.parse text
    
    assert_match("<b><i>bold & italic</i></b>", markup.to_html)
  end

end
