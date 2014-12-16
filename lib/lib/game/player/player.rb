module Hangman
  class Game
    class Player
      attr_accessor :name

      def initialize(options={})
        @name = options[:name].downcase
      end
    end
  end
end
