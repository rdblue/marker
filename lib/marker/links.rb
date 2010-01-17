#--
# Copyright 2009 Ryan Blue.
# Distributed under the terms of the GNU General Public License (GPL).
# See the LICENSE file for further information on the GPL.
#++

require 'marker/common'

module Marker #:nodoc:
  class InternalLink < ParseNode
    def to_html( options = {} )
      "<a href='#{path(options)}'>#{label(:html, options)}</a>"
    end

    def to_s( options = {} )
      f = options[:footnotes]
      if f
        l = label(:text, options)
        n = f.add( path(options), l )
        "#{l} [#{n}]"
      else
        "#{label(:text, options)} [#{path}]"
      end
    end

    def path( options = {} )
      p = options[:link_base] || ''
      p.chomp! '/'
      p += '/' + target
    end

    def label( format, options = {} )
      if l
        case format
        when :html
          l.to_html(options)
        else
          l.to_s(options)
        end
      else
        if a
          # an arg delimiter was present, but without a label
          # sanitize: remove trailing parenthetical remarks
          target.gsub(/\s*\([^)]*\)$/, '')
        else
          target
        end
      end
    end

    def target
      if t
        t.text_value
      else
        ''
      end
    end

    #-- defaults ++
    def t #:nodoc:
      nil
    end

    def a #:nodoc:
      nil
    end

    def l #:nodoc:
      nil
    end
  end

  class ExternalLink < ParseNode
    def to_html( options = {} )
      if l
        "<a href='#{target}'>#{label(:html, options)}</a>"
      else
        f = options[:footnotes]
        if f
          n = f.add( target )
          "<a href='#{target}'>[#{n}]</a>"
        else
          "<a href='#{target}'>#{target}</a>"
        end
      end
    end

    def to_s( options = {} )
      f = options[:footnotes]
      if l
        if f
          n = f.add( target, label(:text, options) )
          "#{label(:text, options)} [#{n}]"
        else
          "#{label(:text, options)} [#{target}]"
        end
      else
        if f
          n = f.add( target )
          "[#{n}]"
        else
          target
        end
      end
    end

    def label( format, options = {} )
      if l
        case format
        when :html
          l.to_html(options)
        else
          l.to_s(options)
        end
      else
        ''
      end
    end

    def target
      if t
        t.text_value
      else
        ''
      end
    end

    #-- defaults ++
    def t #:nodoc:
      nil
    end

    def l #:nodoc:
      nil
    end
  end

  class URL < ParseNode
    def to_html( options = {} )
      f = options[:footnotes]
      if f
        n = f.add( bare_url )
        "<a href='#{bare_url}'>[#{n}]</a>"
      else
        "<a href='#{bare_url}'>#{bare_url}</a>"
      end
    end

    def to_s( options = {} )
      f = options[:footnotes]
      if f
        n = f.add( bare_url )
        "[#{n}]"
      else
        bare_url
      end
    end

    # returns just the URL that was matched
    def bare_url
      text_value
    end
  end

  class Protocol < ParseNode
  end
end
