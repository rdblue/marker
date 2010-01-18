#--
# Copyright 2009 Ryan Blue.
# Distributed under the terms of the GNU General Public License (GPL).
# See the LICENSE file for further information on the GPL.
#++

require 'marker/common'

module Marker #:nodoc:
  class Template < ParseNode
    def to_html( options = {} )
      render( :html, options )
    end

    def to_s( options = {} )
      render( :text, options )
    end

    def render( format, options = {} )
      Marker.templates.send( target, format, *arg_list( format, options ) )
    end

    def target
      # sanitize the string to get a method name
      t.text_value.gsub(/\s/, '_').to_sym
    end

    def arg_list( format, options )
      ( args ? args.to_arg_list( format, options ) : [[], {}] )
    end

    #-- defaults ++
    def t #:nodoc:
      nil
    end

    def args #:nodoc:
      nil
    end
  end

  class Arguments < RecursiveList
    def to_arg_list( format, options = {} )
      pos_params = []
      named_params = {}

      case format
      when :html
        to_a.each do |a|
          next unless a
          value = ( a.val ? a.val.to_html(options) : "" )
          if a.name
            named_params[a.name.to_s(options)] = value
          else
            pos_params << value
          end
        end
      else
        to_a.each do |a|
          next unless a
          value = ( a.val ? a.val.to_s(options) : "" )
          if a.name
            named_params[a.name.to_s(options)] = value
          else
            pos_params << value
          end
        end
      end

      [pos_params, named_params]
    end

    def to_html( options = {} )
      to_a.map { |a|
        a ? a.to_html(options) : ''
      }.join(', ')
    end

    def to_s( options = {} )
      to_a.map { |a|
        a ? a.to_s(options) : ''
      }.join(', ')
    end
  end

  class Argument < ParseNode
    def to_html( options = {} )
      to_s
    end

    def to_s( options = {} )
      ( name ? "'#{name}' => '#{val}'" : "'#{val}'" )
    end

    #-- defaults ++
    def name #:nodoc:
      nil
    end

    def val
      nil
    end
  end

  # A set of basic templates for rendering
  module DefaultTemplates
    def self.method_missing( sym, *args )
      "render:#{sym}( #{args.map(&:inspect).join(', ')} )"
    end
  end
end
