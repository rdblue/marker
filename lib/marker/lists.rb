#--
# Copyright 2009 Ryan Blue.
# Distributed under the terms of the GNU General Public License (GPL).
# See the LICENSE file for further information on the GPL.
#++

require 'marker/common'

module Marker #:nodoc:
  # used to collect list lines into lists structured hierarchically, like in HTML
  class ListBuilder
    attr_reader :tag, :contents, :attrs

    def initialize( contents, tag, attrs = {} )
      @contents = [contents].flatten
      @tag = tag
      @attrs = attrs
    end

    # returns true if the l has the same tag
    def ===( l )
      ( l.is_a? self.class and tag == l.tag )
    end

    def <<( l )
      last = contents.last

      if last and last === l
        last += l
      else
        contents << l
      end

      self
    end

    def +( l )
      l.contents.each { |i| self << i } if self === l

      self
    end

    def to_html( options = {} )
      if tag
        "<#{tag}" +
        ( attrs.any?? ' ' : '' ) +
        attrs.map { |k, v|
          "#{k}='#{v}'"
        }.join(' ') +
        ">" +
        contents.map { |i|
          i.to_html(options)
        }.join +
        "</#{tag}>"
      else
        contents.map { |i|
          i.to_html(options)
        }.join
      end
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

  class List < RecursiveList
    def to_html( options = {} )
      l = ListBuilder.new( [], nil )
      to_a.each do |item|
        l << item.structure
      end
      l.to_html(options)
    end

    def to_s( options = {} )
      l = ListBuilder.new( [], nil )
      to_a.each do |item|
        l << item.structure
      end
      l.to_s(options)
    end
  end

  class Bulleted < ParseNode
    def to_html( options = {} )
      "<li>#{phrase.to_html(options)}</li>"
    end

    def to_s( options = {} )
      indent = (options[:indent] || 0)
      '    ' * (indent > 0 ? indent - 1 : 0) +
      '  * ' + phrase.to_s( options )
    end

    def structure
      if phrase
        ListBuilder.new( self, :ul )
      else
        ListBuilder.new( list_item.structure, :ul )
      end
    end

    #-- defaults ++
    def phrase
      nil
    end
  end

  class Numbered < ParseNode
    def to_html( options = {} )
      "<li>#{phrase.to_html(options)}</li>"
    end

    def to_s( options = {} )
      indent = (options[:indent] || 0)
      '    ' * (indent > 0 ? indent - 1 : 0) +
      '%2d. ' % options[:num]
    end

    def structure
      if phrase
        ListBuilder.new( self, :ol )
      else
        ListBuilder.new( list_item.structure, :ol )
      end
    end

    #-- defaults ++
    def phrase
      nil
    end
  end

  class Indented < ParseNode
    def to_html( options = {} )
      "<div>#{phrase.to_html(options)}</div>"
    end

    def to_s( options = {} )
      indent = (options[:indent] || 0)
      '    ' * (indent > 0 ? indent : 0) +
      phrase.to_s(options)
    end

    def structure
      if phrase
        ListBuilder.new( self, :div, :class => 'indent' )
      else
        ListBuilder.new( list_item.structure, :div, :class => 'indent' )
      end
    end

    #-- defaults ++
    def phrase
      nil
    end
  end

  class Definition < ParseNode
    def to_html( options = {} )
      "<dt>#{term.to_html(options)}</dt>" +
      ( definition ? "<dd>#{definition.to_html(options)}</dd>" : "" )
    end

    def to_s( options = {} )
      indent = (options[:indent] || 0)
      '    ' * (indent > 0 ? indent - 1: 0) +
      "#{term.to_s(options)} :: #{definition.to_s(options)}"
    end

    def structure
      ListBuilder.new( self, :dl )
    end

    #-- defaults ++
    def definition
      nil
    end
  end
end
