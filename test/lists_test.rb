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

  def test_mixed_list
    text = "# List item 1\n* List item 2\n# List item 3"
    markup = Marker.parse text
    
    assert_match("<ol><li>List item 1</li></ol><ul><li>List item 2</li></ul><ol><li>List item 3</li></ol>", markup.to_html)
  end

  def test_nested_mixed_list
    text = "# List item 1\n#* List item 2\n# List item 3\n## List item 4"
    markup = Marker.parse text
    
    assert_match("<ol><li>List item 1</li><ul><li>List item 2</li></ul><li>List item 3</li><ol><li>List item 4</li></ol></ol>", markup.to_html)
  end

end
