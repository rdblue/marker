#--
# Copyright 2009-2012 Ryan Blue.
# Distributed under the terms of the GNU General Public License (GPL).
# See the LICENSE file for further information on the GPL.
#++

require 'marker/common'

module Marker #:nodoc:
  class Document < ParseNode
    def to_html( options = {} )
      options = make_options( options )

      markup ? (
        markup.to_html( options ) + "\n" +
        options[:footnotes].to_html( options )
      ) : ""
    end

    def to_s( options = {} )
      options = make_options( options )


      markup ? (
        markup.to_s( options ) + "\n\n" +
        options[:footnotes].to_s( options )
      ) : ""
    end

    def make_options( user_options )
      o = Marker.render_options.dup
      o.merge!( :link_base => Marker.link_base )
      o.merge!( :footnotes => Footnotes.new ) unless user_options[:nofootnotes]
      o.merge!( user_options )
      o
    end

    #-- defaults ++
    def markup
      nil
    end
  end

  class Markup < RecursiveList
    def to_html( options = {} )
      to_a.map{ |b|
        b.to_html(options)
      }.join("\n")
    end

    def to_s( options = {} )
      to_a.map{ |b|
        b.to_s(options)
      }.join("\n\n")
    end
  end

  class Footnotes
    def notes
      @notes ||= []
    end

    def add( *args )
      notes << args
      notes.size
    end

    def to_html( options = {} )
      return "" unless notes.any?

      "<ol class='footnotes'>" +
      notes.map { |n|
        target = n.shift
        if n.any?
          "<li><a href='#{target}'>#{n.join(' ')}</a></li>"
        else
          "<li><a href='#{target}'>#{target}</a></li>"
        end
      }.join +
      "</ol>"
    end

    def to_s( options = {} )
      return "" unless notes.any?

      s = "\n---- Notes ----\n"
      notes.each_with_index{ |n, i|
        target, *label_words = n
        if label_words.any?
          s << "#{'%2d' % (i + 1)}. #{label_words.join(' ')}: #{target}\n"
        else
          s << "#{'%2d' % (i + 1)}. #{target}\n"
        end
      }

      s
    end
  end
end
