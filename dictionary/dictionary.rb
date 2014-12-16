module Hangman
  class Dictionary
    attr_accessor :words
    def initialize
      @words = File.read("/usr/share/dict/words").split("\n")
    end

    def sample
      words.sample.downcase
    end
  end
end
