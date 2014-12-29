module Hangman
  class Messages
    def retrieve(message_name, *args)
      send(message_name, *args)
    end

    def word_is(word)
      "The word is #{word}"
    end

    def prompt_turn
      "It's your turn. Take a guess."
    end

    def other_players_turn(player)
      "It's #{player.name.capitalize}'s turn"
    end

    def invalid_length
      "Guess must be a single letter. Try again."
    end

    def previously_guessed
      "Letter has already been guessed. Try again."
    end

    def letter_guessed(guesser, letter)
      "#{guesser.capitalize} guessed #{letter}."
    end

    def letters_guessed(guesses)
      "Letters guessed: #{guesses.join(', ')}"
    end

    def game_over(word, winner)
      "Game over. The word was '#{word}'. #{winner.capitalize} wins."
    end
  end
end
