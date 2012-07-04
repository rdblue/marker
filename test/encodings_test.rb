require File.expand_path( File.dirname( __FILE__ ) + '/test_helper' )
require 'marker'

class EncodingsTest < Test::Unit::TestCase

  def test_linux_newlines
    text = "one\ntwo\n\nthree"
    markup = Marker.parse text
    assert_match("<p>one two</p>\n<p>three</p>", markup.to_html)
  end

  def test_windows_newlines
    text = "one\r\ntwo\r\n\r\nthree"
    markup = Marker.parse text
    assert_match("<p>one two</p>\n<p>three</p>", markup.to_html)
  end

  def test_mac_newlines
    text = "one\rtwo\r\rthree"
    markup = Marker.parse text
    assert_match("<p>one two</p>\n<p>three</p>", markup.to_html)
  end

end
