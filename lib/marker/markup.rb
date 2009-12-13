#--
# Copyright 2009 Ryan Blue.
# Distributed under the terms of the GNU General Public License (GPL).
# See the LICENSE file for further information on the GPL.
#++

require 'marker/common'

module Marker #:nodoc:
  class Markup < RecursiveList
    def to_html( options = {} )
      to_a.map{ |b|
        b.to_html(options)
      }.join("\n")
    end

    def to_s( options = {} )
      to_a.map{ |b|
        b.to_s(options)
      }.join("\n")
    end
  end
end
