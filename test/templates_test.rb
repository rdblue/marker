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
    # keep in mind here that the default template rendering (that produces
    # "render:name(*args)") inserts the template arguments by using
    # String#inspect, so everything that is produced will be escaped.
    text = '{{ template | \| | a \= b | \|a, b\| }}'
    markup = parse_with_assertions text
    html = markup.to_html

    # escaping delimiters is not supported (and may not ever be)
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

  def test_verbatim_arg_without_final_newline
    text = "{{ ruby code |\n puts 'hello'}}"
    markup = parse_with_assertions text
    html = markup.to_html

    assert_match("render:ruby_code( :html, [\"<pre>\\nputs 'hello'\\n</pre>\"], {}, #{DEFAULT_OPTIONS} )", html, text)
    assert_match(/<div/, html, text)
  end

  def test_verbatim_arg_without_newline_before_pipe
    text = "{{ ruby code |\n puts 'hello'| another arg }}"
    markup = parse_with_assertions text
    html = markup.to_html

    assert_match("render:ruby_code( :html, [\"<pre>\\nputs 'hello'\\n</pre>\", \"another arg\"], {}, #{DEFAULT_OPTIONS} )", html, text)
    assert_match(/<div/, html, text)
  end

  def test_line_anchored_markup_inside_templates_with_blank_lines
    text = "{{ ruby code |\n puts 'hello'\n\n* list}}"
    markup = parse_with_assertions text
    html = markup.to_html

    assert_match("render:ruby_code( :html, [\"<pre>\\nputs 'hello'\\n</pre>\\n<ul><li>list</li></ul>\"], {}, #{DEFAULT_OPTIONS} )", html, text)
    assert_match(/<div/, html, text)
  end

  def test_multiline_inline_arguments
    text = "this is a {{bold|paragraph\nwith some bold text}} in it."
    markup = parse_with_assertions text
    html = markup.to_html

    assert_match("this is a render:bold( :html, [\"paragraph with some bold text\"], {}, #{DEFAULT_OPTIONS} ) in it.", html, text)
    assert_no_match(/<div/, html, text)
  end

  def test_multiparagraph_inline_arguments
    text = "this is a {{bold|paragraph\n\nwith some bold text}} in it."
    markup = parse_with_assertions text
    html = markup.to_html

    assert_match("this is a <div class=\'bold\'>render:bold( :html, [\"<p>paragraph</p>\\n<p>with some bold text</p>\"], {}, #{DEFAULT_OPTIONS} )</div> in it.", html, text)
    assert_match(/<div/, html, text)
  end

  def test_list_with_starting_newline
    text = "{{ inner list |\n* list item 1\n*list item 2}}"
    markup = parse_with_assertions text
    html = markup.to_html

    assert_match("render:inner_list( :html, [\"<ul><li>list item 1</li><li>list item 2</li></ul>\"], {}, #{DEFAULT_OPTIONS} )", html, text)
    assert_match(/<div/, html, text)
  end

  def test_list_with_starting_unsafe_text
    # you might expect this to render as a two-item list, but this is one of
    # the ways Marker differs with MediaWiki. For consistency, Marker will not
    # treat any text that doesn't appear at the start a line as line anchored
    # markup. Otherwise, cases like this would behave strangely:
    # {{ template | should this be verbatim? }}
    #
    text = "{{ inner list |* list item 1\n*list item 2}}"
    markup = parse_with_assertions text
    html = markup.to_html

    assert_match("render:inner_list( :html, [\"<p>* list item 1</p>\\n<ul><li>list item 2</li></ul>\"], {}, #{DEFAULT_OPTIONS} )", html, text)
    assert_match(/<div/, html, text)
  end

  def test_forced_block_argument
    text = "{{ block |\nnormal text}}"
    markup = parse_with_assertions text
    html = markup.to_html

    assert_match("render:block( :html, [\"<p>normal text</p>\"], {}, #{DEFAULT_OPTIONS} )", html, text)
    assert_match(/<div/, html, text)
  end

end
