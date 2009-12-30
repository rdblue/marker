require File.dirname(__FILE__) + '/test_helper'
require 'marker'

class LinkTest < Test::Unit::TestCase

  def test_internal_link
    text = "[[example_page|Example page]]"
    markup = Marker.parse text
    
    assert_match("<a href='/example_page'>Example page</a>", markup.to_html)
  end

  def test_external_link
    text = "[http://www.example.com Example link]"
    markup = Marker.parse text
    
    assert_match("<a href='http://www.example.com'>Example link</a>", markup.to_html)
  end

  def test_unmarked_external_link
    text = "[http://www.example.com]"
    markup = Marker.parse text
    
    assert_match("<a href='http://www.example.com'>http://www.example.com</a>", markup.to_html)
  end

  def test_external_url
    text = "http://www.example.com"
    markup = Marker.parse text
    
    assert_match("<a href='http://www.example.com'>http://www.example.com</a>", markup.to_html)
  end

end
