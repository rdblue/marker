#--
# Copyright 2009 Ryan Blue.
# Distributed under the terms of the GNU General Public License (GPL).
# See the LICENSE file for further information on the GPL.
#++

require 'treetop'

module Marker #:nodoc:
  # used to add methods to all parse nodes.
  class ParseNode < Treetop::Runtime::SyntaxNode
  end

  # implements collection methods on a list using a recursive grammar definition
  # requires defining +h+ and +r+
  class RecursiveList < ParseNode
    def to_a
      if r
        [h] + r.to_a
      else
        [h]
      end
    end

    def r
      nil
    end
  end
end
