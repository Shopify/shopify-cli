require 'test_helper'

module CLI
  module Kit
    class LevenshteinTest < MiniTest::Test
      # These tests were originally written by Jian Weihang (簡煒航) as part of his work
      # on the jaro_winkler gem. The original code could be found here:
      #   https://github.com/tonytonyjan/jaro_winkler/blob/9bd12421/spec/jaro_winkler_spec.rb
      #
      # Copyright (c) 2014 Jian Weihang

      def test_levenshtein_distance
        assert_distance 1, 'henka', 'henkan'
        assert_distance 0, 'al', 'al'
        assert_distance 2, 'martha', 'marhta'
        assert_distance 4, 'jones', 'johnson'
        assert_distance 2, 'abcvwxyz', 'zabcvwxy'
        assert_distance 2, 'abcvwxyz', 'cabvwxyz'
        assert_distance 2, 'dwayne', 'duane'
        assert_distance 4, 'dixon', 'dicksonx'
        assert_distance 4, 'fvie', 'ten'
        assert_distance 2, 'does_exist', 'doesnt_exist'
        assert_distance 0, 'x', 'x'
      end

      def test_levenshtein_distance_with_utf8_strings
        assert_distance 1, '變形金剛4:絕跡重生', '變形金剛4: 絕跡重生'
        assert_distance 1, '連勝文',             '連勝丼'
        assert_distance 1, '馬英九',             '馬英丸'
        assert_distance 1, '良い',              'いい'
      end

      private

      def assert_distance(score, str1, str2)
        assert_equal score, Levenshtein.distance(str1, str2)
      end
    end
  end
end
