require File.dirname(__FILE__) + '/test_helper'
require 'marker'

class ListTest < Test::Unit::TestCase

  def test_bulleted_list
    text = "* List item 1\n* List item 2"
    markup = Marker.parse text
    
    assert_match("<ul><li>List item 1</li><li>List item 2</li></ul>", markup.to_html)
  end

  def test_nested_bulleted_list
    text = "* List item 1\n** List item 2\n* List item 3"
    markup = Marker.parse text
    
    assert_match("<ul><li>List item 1</li><ul><li>List item 2</li></ul><li>List item 3</li></ul>", markup.to_html)
  end

  def test_numbered_list
    text = "# List item 1\n# List item 2"
    markup = Marker.parse text
    
    assert_match("<ol><li>List item 1</li><li>List item 2</li></ol>", markup.to_html)
  end

  def test_nested_numbered_list
    text = "# List item 1\n## List item 2\n# List item 3"
    markup = Marker.parse text
    
    assert_match("<ol><li>List item 1</li><ol><li>List item 2</li></ol><li>List item 3</li></ol>", markup.to_html)
  end

  def test_definition_list
    text = "; term : definition"
    markup = Marker.parse text

    assert_match("<dl><dt>term</dt><dd>definition</dd></dl>", markup.to_html)
  end

  def test_nested_definition_list
    # definition lists can't be nested, so it should return the markup as normal text
    text = "; term 1 : ; term 2 : definition"
    markup = Marker.parse text

    assert_match("<dl><dt>term 1</dt><dd>; term 2 : definition</dd></dl>", markup.to_html)
  end

  def test_indented_list
    # MediaWiki renders intented lists as definition lists without terms.
    # Marker uses <div> tags instead
  end

  def test_nested_intented_list
  end

  def test_mixed_list
    text = "# List item 1\n* List item 2\n# List item 3\n; List item 4 : definition\n: List item 5\n* List item 6"
    markup = Marker.parse text
    
    assert_match("<ol><li>List item 1</li></ol><ul><li>List item 2</li></ul><ol><li>List item 3</li></ol><dl><dt>List item 4</dt>" +
        "<dd>definition</dd></dl><div class='indent'><div>List item 5</div></div><ul><li>List item 6</li></ul>", markup.to_html)
  end

  def test_nested_mixed_list
    text = "# List item 1\n#* List item 2\n# List item 3\n## List item 4\n#; List item 5 : definition\n#:List item 6"
    markup = Marker.parse text
    
    assert_match("<ol><li>List item 1</li><ul><li>List item 2</li></ul><li>List item 3</li><ol><li>List item 4</li></ol>" +
        "<dl><dt>List item 5</dt><dd>definition</dd></dl><div class='indent'><div>List item 6</div></div></ol>", markup.to_html)
  end

end
