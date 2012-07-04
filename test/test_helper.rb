require 'test/unit'
$LOAD_PATH.unshift File.expand_path( File.dirname(__FILE__) + '/../lib' )

class MarkerTest < Test::Unit::TestCase
  def parse_with_assertions( text )
    tree = nil
    assert_nothing_raised do
      tree = Marker.parse( text )
    end
    assert_not_nil( tree, Marker.parser.failure_reason )
    tree
  end
end
