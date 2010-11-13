#--
# Copyright 2009 Ryan Blue.
# Distributed under the terms of the GNU General Public License (GPL).
# See the LICENSE file for further information on the GPL.
#++

require 'marker/common'

module Marker #:nodoc:
  # used to collect list lines into lists structured hierarchically
  #
  # this class contains logic for combining lists, rendering logic is contained
  # in subclasses like BulletedListBuilder (but not ItemBuilder!).
  #
  # ListBuilders encapsulate a single level of a multi-level list.  The
  # contents of a ListBuilder are either the parsed nodes containing actual
  # text, or recursive ListBuilders that eventually contain a ItemBuilder.  For
  # example:
  #  LB(ol)/LB(ol)/LB(ul)/IB(li)
  #
  # ListBuilders work by having the ability to combine structure, via the +
  # method:
  #  LB(ol)/LB(ol)/LB(ul)/IB(li)
  #     +
  #  LB(ol)/LB(ol)/IB(li)
  #     =
  #  LB(ol)/LB(ol)/LB(ul)/IB(li)
  #              `/IB(li)
  #
  # When new layers are appended to a ListBuilder (via <<), the ListBuilder
  # automatically checks if the new content can be merged into existing
  # content.  If so, the layers are combined.
  #
  # Marker's list types create ListBuilders like those above, depending on the
  # strucure that is parsed.  For the most part, it works like this:
  #  ** text    => LB(ul)/LB(ul)/IB(li)
  #  ##: phrase => LB(ol)/LB(ol)/LB(div.indent)/IB(div)
  #
  # The top-level List class creates a ListBuilder with no contents and then
  # appends the structure of each child, which combines the structures and
  # creates the simplified list so that we end up with list items collected
  # under list types correctly.
  class ListBuilder
    attr_reader :contents

    def initialize( contents = nil )
      @contents = ( contents ? [contents] : [] )
    end

    # returns true if the other has the same type
    def ===( other )
      ( other.is_a? self.class )
    end

    # append a new child to contents.  if that child can be combined with the
    # last child already known, then we add them together.
    #
    # appends a child ListBuilder or syntax node inside the list.  If the new
    # child can be combined with the last child list structure, it is added to
    # that existing child.
    def <<( other )
      last = contents.last

      if last and last === other
        last += other
      else
        contents << other
      end

      self
    end

    # combines this ListBuilder with another by adding the added ListBuilder's
    # children to contents.
    def +( other )
      other.contents.each { |item| self << item } if self === other

      self
    end

    def to_html( options = {} )
      contents_to_html( options )
    end

    def contents_to_html( options = {} )
      contents.map { |item|
        item_to_html( item, options )
      }.join
    end

    def item_to_html( item, options = {} )
      item.to_html( options )
    end

    def to_s( options = {} )
      strs = []
      contents.each_with_index { |i, ind|
        strs << i.to_s( options.merge( 
            :indent => ( options[:indent] || 0 ) + ( tag ? 1 : 0 ),
            :num => ind + 1
          ) )
      }
      strs.join("\n")
    end
  end

  # ItemBuilder is a ListBuilder to encapsulate raw list item contents
  #
  # ItemBuilders are like ListBuilders, but have slightly different rules for
  # combination, because HTML list items contain sub-lists.  This means that
  # IB(li) === LB(ol) and IB(li) === LB(ul), but LB(ol) =/= IB(li).
  class ItemBuilder < ListBuilder
    def ===( other )
      # allow any subclass of ListBuilder except for ItemBuilder
      other.is_a? ListBuilder and not other.is_a? ItemBuilder
    end

    # when ListBuilders are added, we actually append them since the structure
    # needs to be preserved.  For example:
    #  LB(ul)/IB(li)
    #     +
    #  LB(ul)/LB(ol)/IB(li)
    #     =
    #  LB(ul)/IB(li)/LB(ol)/IB(li)
    #
    # this produces HTML:
    #   <ul><li>text<ol><li>phrase</li></ol></li></ul>
    #
    # alternatively, text:
    #    * text
    #       1. phrase
    def +( other )
      self << other # if self === other
    end
  end

  class List < RecursiveList
    def to_html( options = {} )
      l = ListBuilder.new
      to_a.each do |item|
        l << item.structure
      end
      l.to_html(options)
    end

    def to_s( options = {} )
      l = ListBuilder.new
      to_a.each do |item|
        l << item.structure
      end
      l.to_s(options)
    end
  end

  class BulletedListBuilder < ListBuilder
    def to_html( options = {} )
      "<ul>#{contents_to_html(options)}</ul>"
    end

    def item_to_html( item, options = {} )
      "<li>#{item.to_html(options)}</li>"
    end
  end

  class Bulleted < ParseNode
    def to_s( options = {} )
      indent = (options[:indent] || 0)
      '    ' * (indent > 0 ? indent - 1 : 0) +
      '  * ' + phrase.to_s( options )
    end

    def structure
      if phrase
        BulletedListBuilder.new( ItemBuilder.new( phrase ) )
      else
        BulletedListBuilder.new( list_item.structure )
      end
    end

    #-- defaults ++
    def phrase
      nil
    end
  end

  class NumberedListBuilder < ListBuilder
    def to_html( options = {} )
      "<ol>#{contents_to_html(options)}</ol>"
    end

    def item_to_html( item, options = {} )
      "<li>#{item.to_html(options)}</li>"
    end
  end

  class Numbered < ParseNode
    def to_s( options = {} )
      indent = (options[:indent] || 0)
      '    ' * (indent > 0 ? indent - 1 : 0) +
      "#{'%2d' % options[:num]}. #{phrase.to_s( options )}"
    end

    def structure
      if phrase
        NumberedListBuilder.new( ItemBuilder.new( phrase ) )
      else
        NumberedListBuilder.new( list_item.structure )
      end
    end

    #-- defaults ++
    def phrase
      nil
    end
  end

  class IndentedListBuilder < ListBuilder
    def to_html( options = {} )
      "<div class='indent'>#{contents_to_html(options)}</div>"
    end

    def item_to_html( item, options = {} )
      "<div class='indent_item'>#{item.to_html(options)}</div>"
    end
  end

  class Indented < ParseNode
    def to_s( options = {} )
      indent = (options[:indent] || 0)
      '    ' * (indent > 0 ? indent : 0) +
      phrase.to_s(options)
    end

    def structure
      if phrase
        IndentedListBuilder.new( ItemBuilder.new( phrase ) )
      else
        IndentedListBuilder.new( list_item.structure )
      end
    end

    #-- defaults ++
    def phrase
      nil
    end
  end

  class DefinitionListBuilder < ListBuilder
    def to_html( options = {} )
      "<dl>#{contents_to_html(options)}</dl>"
    end

    def item_to_html( item, options = {} )
      term, definition = item
      "<dt>#{term.to_html(options)}</dt>" +
      "<dd>#{definition.to_html(options)}</dd>"
    end
  end

  class Definition < ParseNode
    def to_s( options = {} )
      indent = (options[:indent] || 0)
      '    ' * (indent > 0 ? indent - 1: 0) +
      "#{term.to_s(options)} :: #{definition.to_s(options)}"
    end

    def structure
      DefinitionListBuilder.new( [term, ItemBuilder.new( definition )] )
    end

    #-- defaults ++
    def definition
      nil
    end
  end
end
