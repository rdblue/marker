require File.expand_path( File.dirname( __FILE__ ) + '/test_helper' )
require 'marker'

class TemplatesTest < Test::Unit::TestCase

  DEFAULT_OPTIONS = '{:link_base=>"", :footnotes=>}'

  def test_basic_template
    text = "{{ template }}"
    markup = Marker.parse text
    
    assert_match("<p>render:template( :html, [], {}, #{DEFAULT_OPTIONS} )</p>", markup.to_html)
  end

  def test_positional_args
    text = "{{ template | one | two | three }}"
    markup = Marker.parse text
    
    assert_match("<p>render:template( :html, [\"one\", \"two\", \"three\"], {}, #{DEFAULT_OPTIONS} )</p>", markup.to_html)
  end

  def test_named_args
    text = "{{ template | one=1 | two = 2 }}"
    markup = Marker.parse text
    
    # might want to fix this assertion, the hash could come out in any order
    assert_match("<p>render:template( :html, [], {", markup.to_html)
    assert_match("\"two\"=>\"2\"", markup.to_html)
    assert_match("\"one\"=>\"1\"", markup.to_html)
    assert_match("}, #{DEFAULT_OPTIONS} )</p>", markup.to_html)
  end

  def test_mixed_args
    text = "{{ template | one | two = 2 | three }}"
    markup = Marker.parse text
    
    assert_match("<p>render:template( :html, [\"one\", \"three\"], {\"two\"=>\"2\"}, #{DEFAULT_OPTIONS} )</p>", markup.to_html)
  end

  def test_empty_args
    text = "{{ template | }}"
    markup = Marker.parse text
    assert_match("<p>render:template( :html, [\"\"], {}, #{DEFAULT_OPTIONS} )</p>", markup.to_html)

    text = "{{ template | | }}"
    markup = Marker.parse text
    assert_match("<p>render:template( :html, [\"\", \"\"], {}, #{DEFAULT_OPTIONS} )</p>", markup.to_html)
  end

  def test_rendered_args
    text = "{{ template | [http://www.example.com Example] }}"
    markup = Marker.parse text

    assert_match("<p>render:template( :html, [\"<a href='http://www.example.com'>Example</a>\"], {}, #{DEFAULT_OPTIONS} )</p>", markup.to_html)
  end

  def test_escaped_characters
    # the single quotes are important here, to make sure the "\" are in the actual text
    # this test is messed up right now.  we should have a way to send a single
    # '\' through, but ruby seems to have errors with it!  for now, just removing that case.
    text = '{{ template | \| | a \= b | \|a, b\| }}'
    markup = Marker.parse text

    assert_match("<p>render:template( :html, [\"|\", \"a = b\", \"|a, b|\"], {}, #{DEFAULT_OPTIONS} )</p>", markup.to_html)
  end

  def test_line_anchored_markup_inside_templates
    text = "{{ ruby |\n puts 'hello'\n}}"
  end

end
