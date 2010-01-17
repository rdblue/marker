require File.dirname(__FILE__) + '/test_helper'
require 'marker'

class FormattingTest < Test::Unit::TestCase

  def test_bold_formatting
    text = "'''bold'''"
    markup = Marker.parse text
    
    assert_match("<p><b>bold</b></p>", markup.to_html)
  end

  def test_italic_formatting
    text = "''italic''"
    markup = Marker.parse text
    
    assert_match("<p><i>italic</i></p>", markup.to_html)
  end

  def test_bold_italic_formatting
    # starting and finishing bold-italic
    text = "'''''bold & italic'''''"
    markup = Marker.parse text
    assert_match("<p><b><i>bold & italic</i></b></p>", markup.to_html)

    # starting italic, finishing bold-italic
    text = "''italic'''bold & italic'''''"
    markup = Marker.parse text
    assert_match("<p><i>italic<b>bold & italic</b></i></p>", markup.to_html)

    # starting bold, finishing bold-italic
    text = "'''bold''bold & italic'''''"
    markup = Marker.parse text
    assert_match("<p><b>bold<i>bold & italic</i></b></p>", markup.to_html)

    # starting bold-italic, finishing bold
    text = "'''''bold & italic''bold'''"
    markup = Marker.parse text
    assert_match("<p><b><i>bold & italic</i>bold</b></p>", markup.to_html)

    # starting bold-italic, finishing italic
    #
    # known issue: this doesn't work as "expected" due to treetop's
    # short-circuiting (PEG); note that the opposite (bold outside italic)
    # works fine
    #
    # TODO: maybe catch this case with a special grammar rule?
    #
    # doesn't work:
    text = "'''''word'''word''"
    markup = Marker.parse text
    assert_match("<p>'''<i>word</i>'word''</p>", markup.to_html)
    # works fine if given a space to be more clear:
    text = "'' '''bold & italic'''italic''"
    markup = Marker.parse text
    assert_match("<p><i><b>bold & italic</b>italic</i></p>", markup.to_html)

    # improper nesting
    #
    # marker will not catch improper nesting:
    # * MediaWiki: <p><i>one<b>two</b></i><b>three</b></p>
    # * Marker: <p><i>one</i>'two<i>three</i>'</p>
    text = "''one'''two''three'''"
    markup = Marker.parse text
    assert_match("<p><i>one</i>'two<i>three</i>'</p>", markup.to_html)
  end

  def test_paragraphs
    text = "paragraph 1\n\nparagraph 2\n\nparagraph 3"
    markup = Marker.parse text

    assert_match("<p>paragraph 1</p>\n\n<p>paragraph 2</p>\n\n<p>paragraph 3</p>", markup.to_html)
  end

  def test_newlines_in_paragraphs
    # text lines separated by only one newline
    # this matches how MediaWiki renders
    text = "word1\nword2\nword3"
    markup = Marker.parse text

    assert_match("<p>word1 word2 word3</p>", markup.to_html)
  end

  def test_horizontal_rule
    text = "----"
    markup = Marker.parse text
    
    assert_match("<hr />\n", markup.to_html)
  end

  # FIXME: throws NoMethodError
  def test_invalid_horizontal_rule
    text = "---- ----"
    markup = Marker.parse text
    
    assert_match("<hr />\n<p>----</p>", markup.to_html)
  end

end
