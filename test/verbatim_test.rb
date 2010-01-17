require File.dirname(__FILE__) + '/test_helper'
require 'marker'

class VerbatimTest < Test::Unit::TestCase

  def test_preformatted_text
    text = " some source code"
    markup = Marker.parse text
    
    assert_match("<pre>\nsome source code\n</pre>", markup.to_html)
  end

  def test_multiline_preformatted_text
    text = " some source code\n some more source code"
    markup = Marker.parse text
    
    assert_match("<pre>\nsome source code\nsome more source code\n</pre>", markup.to_html)
  end

end
