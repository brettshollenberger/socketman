module Hangman
  class Word < String
    class InvalidGuessError < StandardError; end

    attr_accessor :secret

    def initialize(options={})
      @secret = options[:secret] || random_secret

      dasherize
    end

    def guess(letter)
      protect_invalid_guesses(letter)

      letter = letter.downcase

      secret.chars.each_with_index do |letter_in_word, index|
        if letter == letter_in_word
          self[index] = letter
        end
      end
    end

    def solved?
      self == secret
    end

  private
    def protect_invalid_guesses(letter)
      unless letter.length == 1
        raise InvalidGuessError, "Guess must be a single letter. Got '#{letter}'"
      end
    end

    def dasherize
      if empty?
        self << @secret.gsub(/\w/) { |letter| "-" }
      end
    end

    def random_secret
      dictionary.sample
    end

    def dictionary
      @dictionary ||= Hangman::Dictionary.new
    end
  end
end
