#--
# Copyright 2009 Ryan Blue.
# Distributed under the terms of the GNU General Public License (GPL).
# See the LICENSE file for further information on the GPL.
#++

require 'marker/common'

module Marker #:nodoc:
  class Paragraph < RecursiveList
    def to_html( options = {} )
      '<p>' +
      to_a.map { |p|
        p.to_html(options)
      }.join(' ') +
      '</p>'
    end

    # TODO: add wordwrap
    def to_s( options = {} )
      to_a.map { |p|
        p.to_s(options)
      }.join(' ')
    end
  end

  class Phrase < RecursiveList
    def to_html( options = {} )
      s = h.to_html(options)
      s << ' ' if space?
      s << r.to_html(options) if r
      s
    end

    def to_s( options = {} )
      s = h.to_s(options)
      s << ' ' if space?
      s << r.to_s(options) if r
      s
    end

    # returns true if there was white space after the first "word"
    def space?
      (ws and ws.present?) or (aws and aws.present?)
    end

    #-- defaults ++
    def ws
      nil
    end

    def aws
      nil
    end
  end

  class Word < ParseNode
    def to_html( options = {} )
      text_value
    end

    def to_s( options = {} )
      text_value
    end
  end

  class Delimiter < ParseNode
    def to_html( options = {} )
      text_value
    end

    def to_s( options = {} )
      text_value
    end
  end

  class HorizRule < ParseNode
    def to_html( options = {} )
      "<hr />" +
      ( t ? "\n#{t.to_html(options)}" : "" )
    end

    def to_s( options = {} )
      width = options[:width] || 80
      "-" * width +
      ( t ? "\n#{t.to_s(options)}" : "" )
    end

    def t
      nil
    end
  end

  class Bold < ParseNode
    def to_html( options = {} )
      "<b>#{bold_enclosed_text.to_html(options)}</b>"
    end

    def to_s( options = {} )
      "*#{bold_enclosed_text.to_s(options)}*"
    end
  end

  class Italic < ParseNode
    def to_html( options = {} )
      "<i>#{italic_enclosed_text.to_html(options)}</i>"
    end

    def to_s( options = {} )
      "/#{italic_enclosed_text.to_s(options)}/"
    end
  end
end
