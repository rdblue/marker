#--
# Copyright 2009 Ryan Blue.
# Distributed under the terms of the GNU General Public License (GPL).
# See the LICENSE file for further information on the GPL.
#++

require 'marker/common'

module Marker #:nodoc:
  class ListBuilder
    attr_reader :type
    attr_reader :items

    def initialize( type, item=nil )
      @type = type
      @items = (item ? [item] : [])
    end

    def can_merge?( other )
      type == other.type
    end

    def merge!( list )
      list.items.each { |item| add( item ) }
    end

    def add( item )
      if items.last and items.last.can_merge? item
        items.last.merge! item
      else
        items << item
      end
    end

    def empty?
      items.empty?
    end

    def to_html( options={} )
      inner_html = items.map { |item| item.to_html(options) }.join
      case type
      when :bulleted
        "<ul>#{inner_html}</ul>"
      when :numbered
        "<ol>#{inner_html}</ol>"
      when :indented
        "<div class='indent'>#{inner_html}</div>"
      when :definition
        "<dl>#{inner_html}</dl>"
      else
        inner_html
      end
    end

    def to_s( options={} )
      indent = (options[:indent] ? options[:indent] + 1 : -1)
      # sublists are already indented because they are part of an item.
      indent -= 1 if type == :sublist

      case type
      when :numbered
        items.each_with_index.map { |item, num|
          item.to_s(options.merge(:indent => indent, :num => num))
        }.join("\n")
      else
        items.map { |item|
          item.to_s(options.merge(:indent => indent))
        }.join("\n")
      end
    end
  end

  class ItemBuilder
    attr_reader :type
    attr_reader :content
    attr_reader :sublists

    def initialize( type, content_or_sublist )
      @type = type

      if content_or_sublist.respond_to? :items
        @content = nil
        @sublists = ListBuilder.new(:sublist, content_or_sublist)
      else
        @content = content_or_sublist
        @sublists = ListBuilder.new(:sublist)
      end
    end

    def can_merge?( other )
      other.content.nil?
    end

    def merge!( item )
      sublists.merge! item.sublists
    end

    def to_html( options={} )
      case type
      when :bulleted, :numbered
        "<li>" +
          ( content ? content.to_html(options) : "" ) +
          sublists.to_html(options) +
        "</li>"
      when :indented
        "<div class='indented_item'>" +
          ( content ? content.to_html(options) : "" ) +
          sublists.to_html(options) +
        "</div>"
      when :definition
        if content
          term, definition = content
          "<dt>#{term.to_html(options)}</dt><dd>#{definition.to_html(options)}#{sublists.to_html(options)}</dd>"
        else
          "<dd>#{sublists.to_html(options)}</dd>"
        end
      end
    end

    def to_s( options={} )
      if content
        indent = '    ' * options[:indent]
        item_str = case type
          when :bulleted
            '  * ' + content.to_s(options)
          when :numbered
            "#{'%2d' % (options[:num]+1)}. " + content.to_s(options)
          when :indented
            '    ' + content.to_s(options)
          when :definition
            term, definition = content
            '    ' + term.to_s(options) + ( definition ? ' :: ' + definition.to_s(options) : '' )
          end
        sublist_str = ( sublists.empty? ? '' : "\n#{sublists.to_s(options)}" )
        "#{indent}#{item_str}#{sublist_str}"
      else
        sublists.to_s(options)
      end
    end
  end

  class List < RecursiveList
    def builder
      list_builder = ListBuilder.new(:root)
      to_a.each do |node|
        list_builder.add( node.builder )
      end
      list_builder
    end

    def to_html( options = {} )
      builder.to_html(options)
    end

    def to_s( options = {} )
      builder.to_s(options)
    end
  end

  class ListNode < ParseNode
    def builder
      if content
        ListBuilder.new( type, ItemBuilder.new( type, content ) )
      else
        ListBuilder.new( type, ItemBuilder.new( type, item.builder ) )
      end
    end
  end

  class Bulleted < ListNode
    def type
      :bulleted
    end

    #-- defaults ++
    def content
      nil
    end
  end

  class Numbered < ListNode
    def type
      :numbered
    end

    #-- defaults ++
    def content
      nil
    end
  end

  class Indented < ListNode
    def type
      :indented
    end

    #-- defaults ++
    def content
      nil
    end
  end

  class Definition < ListNode
    def type
      :definition
    end

    def content
      [term, definition]
    end

    #-- defaults ++
    def definition
      nil
    end
  end
end

