require File.dirname(__FILE__) + '/test_helper'
require 'marker'

class LinkTest < Test::Unit::TestCase

  def test_internal_link_with_alias
    text = "[[example_page|Example page]]"
    markup = Marker.parse text
    
    assert_match("<a href='/example_page'>Example page</a>", markup.to_html)
  end

  def test_bare_internal_link
    text = "[[Example page]]"
    markup = Marker.parse text
    
    assert_match("<a href='/Example page'>Example page</a>", markup.to_html)
  end

  def test_internal_link_with_sanitization
    # parens aren't normally sanitized
    text = "[[Example page (disambiguation)]]"
    markup = Marker.parse text
    assert_match("<a href='/Example page (disambiguation)'>Example page (disambiguation)</a>", markup.to_html)

    # with a blank alias, parens are sanitized from the alias
    text = "[[Example page (disambiguation)|]]"
    markup = Marker.parse text
    assert_match("<a href='/Example page (disambiguation)'>Example page</a>", markup.to_html)

    # no effect without parens
    text = "[[Example page|]]"
    markup = Marker.parse text
    assert_match("<a href='/Example page'>Example page</a>", markup.to_html)
  end

  def test_internal_with_url
    text = "[[http://www.example.com]]"
    markup = Marker.parse text
    assert_match("<p><a href='http://www.example.com'>[1]</a></p>\n<ol><li><a href='http://www.example.com'>http://www.example.com</a></li></ol>", markup.to_html)

    text = "[[http://www.example.com|Example page]]"
    markup = Marker.parse text
    assert_match("<a href='http://www.example.com'>Example page</a>", markup.to_html)

    text = "[[http://www.example.com Example page]]"
    markup = Marker.parse text
    assert_match("<a href='http://www.example.com'>Example page</a>", markup.to_html)
  end

  def test_external_link_with_alias
    text = "[http://www.example.com Example link]"
    markup = Marker.parse text
    
    assert_match("<a href='http://www.example.com'>Example link</a>", markup.to_html)
  end

  def test_bare_external_link
    text = "[http://www.example.com]"
    markup = Marker.parse text

    assert_match("<p><a href='http://www.example.com'>[1]</a></p>\n<ol><li><a href='http://www.example.com'>http://www.example.com</a></li></ol>", markup.to_html)
  end

  def test_nested_links
    # only the outside link works
    text = "[http://www.example.com [[ Nested Internal ]]]"
    markup = Marker.parse text
    assert_match("<p><a href='http://www.example.com'>[[ Nested Internal ]]</a></p>", markup.to_html)

    text = "[[Internal | [http://www.example.com Nested] ]]"
    markup = Marker.parse text
    assert_match("<p><a href='/Internal'>[http://www.example.com Nested]</a></p>", markup.to_html)

    text = "[[Internal | [http://www.example.com Nested]]]"
    markup = Marker.parse text
    assert_match("<p><a href='/Internal'>[http://www.example.com Nested</a>]</p>", markup.to_html)
  end

  def test_implicit_urls
    # implicit urls are url-safe strings used in external links.  e.g., apt: or itunes: urls
    # alone, they render as text:
    text = "apt:ruby1.8"
    markup = Marker.parse text
    assert_match("<p>apt:ruby1.8</p>", markup.to_html)

    # placed in a url context, they render as urls:
    text = "[apt:ruby1.8 Install Ruby!]"
    markup = Marker.parse text
    assert_match("<a href='apt:ruby1.8'>Install Ruby!</a>", markup.to_html)
  end

  def test_bare_url
    text = "http://www.example.com"
    markup = Marker.parse text
    
    assert_match("<p><a href='http://www.example.com'>[1]</a></p>\n<ol><li><a href='http://www.example.com'>http://www.example.com</a></li></ol>", markup.to_html)
  end

  def test_multiple_footnotes
    text = "http://www.example.com [http://www.example.com]"
    markup = Marker.parse text

    # TODO: should this collect identical links into one footnote?
    assert_match("<p><a href='http://www.example.com'>[1]</a> <a href='http://www.example.com'>[2]</a></p>\n" +
        "<ol><li><a href='http://www.example.com'>http://www.example.com</a></li><li><a href='http://www.example.com'>http://www.example.com</a></li></ol>", markup.to_html)
  end

end
