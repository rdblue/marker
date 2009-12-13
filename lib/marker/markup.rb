#--
# Copyright 2009 Ryan Blue.
# Distributed under the terms of the GNU General Public License (GPL).
# See the LICENSE file for further information on the GPL.
#++

require 'marker/common'

module Marker #:nodoc:
  class Markup < RecursiveList
    def to_html( options = {} )
      options[:footnotes] = Footnotes.new

      [
        to_a.map{ |b|
          b.to_html(options)
        }, options[:footnotes].to_html( options )
      ].flatten.join("\n")
    end

    def to_s( options = {} )
      options[:footnotes] = Footnotes.new

      [
        to_a.map{ |b|
          b.to_s(options)
        }, options[:footnotes].to_s( options )
      ].flatten.join("\n")
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

      "<ol>" +
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

      s = "\n"
      notes.each_with_index{ |n, i|
        target = n.shift
        if n.any?
          s << "#{'%2d' % (i + 1)}. #{n.join(' ')}: #{target}\n"
        else
          s << "#{'%2d' % (i + 1)}. #{target}\n"
        end
      }

      s
    end
  end
end
