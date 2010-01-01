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

  def test_paragraphs
    text = "paragraph 1\n\nparagraph 2\n\nparagraph 3"
    markup = Marker.parse text

    assert_match("<p>paragraph 1</p><p>paragraph 2</p><p>paragraph 3</p>", markup.to_html)
  end

  # TODO: verify that the asserted behavior is the desired. MediaWiki
  # leaves the newlines without a <br/>, but I think that is unintuitive,
  # especially when pasting text from other sources 
  def test_newlines
    text = "line 1\nline 2\nline 3"
    markup = Marker.parse text

    assert_match("<p>line 1<br/>line 2<br/>line 3</p>", markup.to_html)
  end

end
