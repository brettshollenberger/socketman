module Hangman
  class Game
    class Players < Array
      def <<(player)
        push(Hangman::Game::Player.new(player))
      end
    end
  end
end
