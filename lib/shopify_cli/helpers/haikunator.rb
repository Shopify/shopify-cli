# Copyright (c) 2015 Usman Bashir
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require "securerandom"

module ShopifyCLI
  module Helpers
    module Haikunator
      class << self
        def title
          build(0, " ")
        end

        def haikunate(token_range = 9999, delimiter = "-")
          build(token_range, delimiter)
        end

        def name
          first = nouns[random_seed % nouns.length]
          last = adjectives[random_seed % adjectives.length]
          [first, last]
        end

        private

        def build(token_range, delimiter)
          sections = [
            adjectives[random_seed % adjectives.length],
            nouns[random_seed % nouns.length],
            token(token_range),
          ]

          sections.compact.join(delimiter)
        end

        def random_seed
          SecureRandom.random_number(4096)
        end

        def token(range)
          SecureRandom.random_number(range) if range > 0
        end

        def adjectives
          %w(
            autumn hidden bitter misty silent empty dry dark summer
            icy delicate quiet white cool spring winter patient
            twilight dawn crimson wispy weathered blue billowing
            broken cold damp falling frosty green long late lingering
            bold little morning muddy old red rough still small
            sparkling throbbing shy wandering withered wild black
            young holy solitary fragrant aged snowy proud floral
            restless divine polished ancient purple lively nameless
          )
        end

        def nouns
          %w(
            waterfall river breeze moon rain wind sea morning
            snow lake sunset pine shadow leaf dawn glitter forest
            hill cloud meadow sun glade bird brook butterfly
            bush dew dust field fire flower firefly feather grass
            haze mountain night pond darkness snowflake silence
            sound sky shape surf thunder violet water wildflower
            wave water resonance sun wood dream cherry tree fog
            frost voice paper frog smoke star
          )
        end
      end
    end
  end
end
