require File.dirname(__FILE__) + '/test_helper'
require 'marker'

class TemplatesTest < Test::Unit::TestCase

  def test_basic_template
    text = "{{ template }}"
    markup = Marker.parse text
    
    assert_match("<p>render:template( :html, [], {} )</p>", markup.to_html)
  end

  def test_positional_args
    text = "{{ template | one | two | three }}"
    markup = Marker.parse text
    
    assert_match("<p>render:template( :html, [\"one\", \"two\", \"three\"], {} )</p>", markup.to_html)
  end

  def test_named_args
    text = "{{ template | one=1 | two = 2 }}"
    markup = Marker.parse text
    
    # might want to fix this assertion, the hash could come out in any order
    assert_match("<p>render:template( :html, [], {\"two\"=>\"2\", \"one\"=>\"1\"} )</p>", markup.to_html)
  end

  def test_mixed_args
    text = "{{ template | one | two = 2 | three }}"
    markup = Marker.parse text
    
    assert_match("<p>render:template( :html, [\"one\", \"three\"], {\"two\"=>\"2\"} )</p>", markup.to_html)
  end

  def test_empty_args
    text = "{{ template | }}"
    markup = Marker.parse text
    assert_match("<p>render:template( :html, [\"\"], {} )</p>", markup.to_html)

    text = "{{ template | | }}"
    markup = Marker.parse text
    assert_match("<p>render:template( :html, [\"\", \"\"], {} )</p>", markup.to_html)
  end

  def test_rendered_args
    text = "{{ template | [http://www.example.com Example] }}"
    markup = Marker.parse text

    assert_match("<p>render:template( :html, [\"<a href='http://www.example.com'>Example</a>\"], {} )</p>", markup.to_html)
  end

end
