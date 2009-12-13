#--
# Copyright 2009 Ryan Blue.
# Distributed under the terms of the GNU General Public License (GPL).
# See the LICENSE file for further information on the GPL.
#++

require 'marker/common'

module Marker #:nodoc:
  class Template < ParseNode
    # TODO: write me
    def to_html( options = {} )
      "render:#{plain_text}(#{args ? args.to_html(options) : ''})"
    end

    def to_s( options = {} )
      "render:#{plain_text}(#{args ? args.to_s(options) : ''})"
    end

    def arg_list
      ( args ? args.to_arg_list : [[], {}] )
    end

    #-- defaults ++
    def args #:nodoc:
      nil
    end
  end

  class Arguments < RecursiveList
    def to_arg_list
      pos_params = []
      named_params = {}
      to_a.each do |a|
        if a.name
          named_params[a.name] = a.val
        else
          pos_params << a.val
        end
      end
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
      ( name ? "'#{name}' => '#{val}'" : "'#{val}'" )
    end

    def to_s( options = {} )
      ( name ? "'#{name}' => '#{val}'" : "'#{val}'" )
    end

    #-- defaults ++
    def name #:nodoc:
      nil
    end
  end
end
