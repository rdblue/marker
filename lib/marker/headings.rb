#--
# Copyright 2009 Ryan Blue.
# Distributed under the terms of the GNU General Public License (GPL).
# See the LICENSE file for further information on the GPL.
#++

require 'marker/common'

module Marker #:nodoc:
  class Heading < ParseNode
    # HTML-rendered headings, using <h#> tags.
    def to_html( options = {} )
      # find out how deep it is
      d = [s.text_value.size, e.text_value.size].min
      sn = s.text_value.size - d
      en = e.text_value.size - d
      if sn > 0
        "<h#{d}>#{'=' * sn} #{label}</h#{d}>"
      elsif en > 0
        "<h#{d}>#{label} #{'=' * en}</h#{d}>"
      else
        "<h#{d}>#{label}</h#{d}>"
      end
    end

    # Text-rendered headings.  Should look like this:
    #
    # Heading Level 1
    # ==========================================================================
    #
    # Heading Level 2
    # --------------------------------------------------------------------------
    #
    # - Heading Level 3 --------------------------------------------------------
    #
    # --- Heading Level 4 ------------------------------------------------------
    #
    def to_s( options = {} )
      width = options[:width] || 80
      d = [s.text_value.size, e.text_value.size].min
      sn = s.text_value.size - d
      en = e.text_value.size - d

      l = if sn > 0
        "#{'=' * sn} #{label}"
      elsif en > 0
        "#{label} #{'=' * en}"
      else
        label
      end

      case d
      when 1
        "#{l}\n" + ('=' * width)
      when 2
        "#{l}\n" + ('-' * width)
      else
        l = " #{l} "
        h = '-'*width
        h[2*(d-3)+1, l.size] = l # slice substitution
        h
      end
    end

    def label( options = {} )
      l.text_value
    end

    #-- defaults ++
    def l #:nodoc:
      nil
    end
  end
end
