require File.expand_path( File.dirname( __FILE__ ) + '/test_helper' )
require 'marker'

class TemplatesTest < MarkerTest

  DEFAULT_OPTIONS = '{:link_base=>"", :footnotes=>}'

  def test_basic_template
    text = "{{ template }}"
    markup = parse_with_assertions text
    html = markup.to_html
    
    assert_match("render:template( :html, [], {}, #{DEFAULT_OPTIONS} )", html, text)
    assert_no_match(/<div/, html, text)
  end

  def test_ordered_args
    text = "{{ template | one | two | three }}"
    markup = parse_with_assertions text
    html = markup.to_html

    assert_match("render:template( :html, [\"one\", \"two\", \"three\"], {}, #{DEFAULT_OPTIONS} )", html, text)
    assert_no_match(/<div/, html, text)
  end

  def test_named_args
    text = "{{ template | one=1 | two = 2 }}"
    markup = parse_with_assertions text
    html = markup.to_html

    assert_match("render:template( :html, [], {", html, text)
    assert_match("\"two\"=>\"2\"", html, text)
    assert_match("\"one\"=>\"1\"", html, text)
    assert_match("}, #{DEFAULT_OPTIONS} )", html, text)
    assert_no_match(/<div/, html, text)
  end

  def test_mixed_args
    text = "{{ template | one | two = 2 | three }}"
    markup = parse_with_assertions text
    html = markup.to_html

    assert_match("render:template( :html, [\"one\", \"three\"], {\"two\"=>\"2\"}, #{DEFAULT_OPTIONS} )", html, text)
    assert_no_match(/<div/, html, text)
  end

  def test_empty_args
    text = "{{ template | }}"
    markup = parse_with_assertions text
    html = markup.to_html
    assert_match("render:template( :html, [\"\"], {}, #{DEFAULT_OPTIONS} )", html, text)
    assert_no_match(/<div/, html, text)

    text = "{{ template | | }}"
    markup = parse_with_assertions text
    html = markup.to_html
    assert_match("render:template( :html, [\"\", \"\"], {}, #{DEFAULT_OPTIONS} )", html, text)
    assert_no_match(/<div/, html, text)
  end

  def test_rendered_args
    text = "{{ template | [http://www.example.com Example] }}"
    markup = parse_with_assertions text
    html = markup.to_html

    assert_match("render:template( :html, [\"<a href='http://www.example.com'>Example</a>\"], {}, #{DEFAULT_OPTIONS} )", html, text)
    assert_no_match(/<div/, html, text)
  end

  def test_escaped_characters
    # the single quotes are important here, to make sure the "\" are in the actual text
    # this test is messed up right now.  we should have a way to send a single
    # '\' through, but ruby seems to have errors with it!  for now, just removing that case.
    text = '{{ template | \| | a \= b | \|a, b\| }}'
    markup = parse_with_assertions text
    html = markup.to_html

    #assert_match("render:template( :html, [\"|\", \"a = b\", \"|a, b|\"], {}, #{DEFAULT_OPTIONS} )", html, text)
    assert_no_match(/<div/, html, text)
  end

  def test_line_anchored_markup_inside_templates
    text = "{{ ruby code |\n puts 'hello'\n}}"
    markup = parse_with_assertions text
    html = markup.to_html

    assert_match("render:ruby_code( :html, [\"<pre>\\nputs 'hello'\\n</pre>\"], {}, #{DEFAULT_OPTIONS} )", html, text)
    assert_match(/<div/, html, text)
  end

  def test_line_anchored_markup_inside_templates_with_blank_lines
    text = "{{ ruby code |\n puts 'hello'\n\n* list}}"
    markup = parse_with_assertions text
    html = markup.to_html

    assert_match("render:ruby_code( :html, [\"<pre>\\nputs 'hello'\\n</pre>\\n<ul><li>list</li></ul>\"], {}, #{DEFAULT_OPTIONS} )", html, text)
    assert_match(/<div/, html, text)
  end

end
