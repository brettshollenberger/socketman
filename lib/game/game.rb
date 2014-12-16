module Hangman
  class Game
    attr_accessor :word, :players, :turn, :current_player, :runner, :messages, :guesses, :current_error

    def initialize(options={})
      @word     = Hangman::Word.new(options)
      @players  = Hangman::Game::Players.new
      @messages = Hangman::Messages.new
      @turn     = 0
      @guesses  = []
    end

    def play
      take_turn until over?
      game_over
    end

    def over?
      word.solved?
    end

    def current_player
      players[self.turn]
    end

    def take_turn
      notify_word
      prompt_turn
      guess_letter
      select_winner if over?
      switch_turn
    end

    def select_winner
      @winner = current_player
    end

  private
    def switch_turn
      self.turn += 1

      if current_player.nil?
        self.turn = 0
      end
    end

    def game_over
      players.each do |player|
        runner.write(player, message(:game_over, word, @winner.name))
      end
    end

    def prompt_turn
      runner.write(current_player, message(:prompt_turn))
    end

    def guess_letter
      until valid_guess?(guessed_letter = runner.read(current_player))
        runner.write(current_player, message(current_error))
      end

      word.guess guessed_letter
      guesses << guessed_letter

      notify_guess(current_player, guessed_letter)
    end

    def valid_guess?(guessed_letter)
      unless guessed_letter.length == 1
        self.current_error = :invalid_length
        return false
      end

      if guesses.include?(guessed_letter)
        self.current_error = :previously_guessed
        return false
      end

      true
    end

    def notify_word
      players.each do |player|
        runner.write(player, message(:word_is, word))
      end
    end

    def notify_guess(current_player, guessed_letter)
      players.each do |player|
        name = player == current_player ? "you" : current_player.name

        runner.write(player, message(:letter_guessed, name, guessed_letter))
        runner.write(player, message(:letters_guessed, guesses))
      end
    end

    def message(message_name, *args)
      messages.retrieve(message_name, *args)
    end
  end
end
