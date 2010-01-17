#--
# Copyright 2009 Ryan Blue.
# Distributed under the terms of the GNU General Public License (GPL).
# See the LICENSE file for further information on the GPL.
#++

require 'marker/common'

module Marker #:nodoc:
  class VerbatimArea < RecursiveList
    def to_html( options = {} )
      "<pre>\n" +
      to_a.map { |l|
        l.to_html(options)
      }.join("\n") +
      "\n</pre>"
    end

    def to_s( options = {} )
      "-- \n" +
      to_a.map { |l|
        l.to_s(options)
      }.join("\n") +
      "\n-- "
    end
  end

  class Verbatim < ParseNode
    def to_html( options = {} )
      v.text_value
    end

    def to_s( options = {} )
      v.text_value
    end
  end
end
