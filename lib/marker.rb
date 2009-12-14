#--
# Copyright 2009 Ryan Blue.
# Distributed under the terms of the GNU General Public License (GPL).
# See the LICENSE file for further information on the GPL.
#++

require 'rubygems'
require 'treetop'

#-- markup classes ++

require 'marker/common'
require 'marker/markup'
require 'marker/text'
require 'marker/headings'
require 'marker/lists'
require 'marker/links'
require 'marker/templates'
require 'marker/verbatim'

#-- markup grammar/parser ++

require 'marker/language'

#:include:README
module Marker
  class << self
    # Adds the instance methods of +mod+ to the templates that will be used
    # when rendering text.
    #
    #   module Templates
    #     # defines {{ name }}
    #     def name( format, positional_array, named_hash )
    #       # return a string!
    #     end
    #   end
    #   Marker.templates = Templates
    def templates=( mod )
      @@templates = Marker::DefaultTemplates.extend( mod )
    end

    def templates #:nodoc:
      @@templates ||= Marker::DefaultTemplates
    end

    # Sets the base url for internal links.  If not set, internal links will
    # begin with '/'
    def link_base=( url )
      @@link_base = url
    end

    def link_base #:nodoc:
      @@link_base ||= ''
    end

    # sets the default options used when rendering markup
    def render_options=( options )
      @@render_options = options
    end

    def render_options #:nodoc:
      @@render_options ||= {}
    end

    # Returns a Marker markup parser instance (Marker::LanguageParser)
    def parser
      @@parser ||= LanguageParser.new
    end

    # Parses the given +markup+ string and returns the result
    def parse( markup )
      parser.parse( markup )
    end

    # Parses markup read from the file +filename+ and returns the result
    def parse_file( filename )
      parser.parse( File.read( filename ) )
    end
  end
end
