#--
# Copyright 2009-2011 Ryan Blue.
# Distributed under the terms of the GNU General Public License (GPL).
# See the LICENSE file for further information on the GPL.
#++

require 'marker/common'

module Marker #:nodoc:
  class Template < ParseNode
    def to_html( options = {} )
      # if this template contains block-style arguments, then it needs to be
      # wrapped in a div.  otherwise, all arguments are inline and it does not
      # get wrapped.  the template target is used as the html class.
      #
      # it may be a good idea to wrap inline templates in a span
      if block?
        "<div class='#{target}'>#{render( :html, options )}</div>"
      else
        render( :html, options )
      end
    end

    def to_s( options = {} )
      render( :text, options )
    end

    def render( format, options = {} )
      # optionally change the format for argument rendering
      if options[:template_formats] and options[:template_formats][target]
        format = options[:template_formats][target]
      end

      ordered, named = arg_list( format, options )
      Marker.templates.send( target, format, ordered, named, options )
    end

    def target
      # sanitize the string to get a method name
      t.text_value.downcase.gsub(/\s/, '_').to_sym
    end

    def arg_list( format, options )
      ( args ? args.to_arg_list( format, options ) : [[], {}] )
    end

    def block?
      ( args ? args.block? : false )
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
      when :raw
        # don't render the text, just return the original value
        # this is needed for special templates, like syntax highlighting
        to_a.each do |a|
          pos_params << a.text_value if a
        end
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

    # returns true if there are any block-style arguments and false if all
    # arguments are inline-style
    def block?
      to_a.map(&:block?).reduce { |a, b| a or b }
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

    # is this argument a block style?
    def block?
      true
    end

    #-- defaults ++
    def name #:nodoc:
      nil
    end

    def val
      nil
    end
  end

  # allow the grammar to distinguish between argument styles, but they render
  # no differently at the argument level.  these allow a template to decide
  # whether it needs to be wrapped in a div for html output.
  class InlineArgument < Argument
    def block?
      false
    end
  end

  class BlockArgument < Argument; end

  # A set of basic templates for rendering
  module DefaultTemplates
    def self.method_missing( sym, *args )
      "render:#{sym}( #{args.map(&:inspect).join(', ')} )"
    end
  end
end
