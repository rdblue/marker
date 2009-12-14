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
  def self.parser
    LanguageParser.new
  end

  def self.parse( markup )
    parser.parse( markup )
  end

  def self.parse_file( filename )
    parser.parse( File.read( filename ) )
  end
end
