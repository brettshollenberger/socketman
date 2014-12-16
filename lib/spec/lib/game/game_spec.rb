require "spec_helper"

describe Hangman::Game do
  before(:each) do
    @game = Hangman::Game.new(:secret => "fun")

    @server            = Hangman::Server.new(:game => @game)
    @bretts_connection = StringIO.new
    @coreys_connection = StringIO.new

    @server.add_connection({ :name => "Brett", :connection => @bretts_connection })
    @server.add_connection({ :name => "Corey", :connection => @coreys_connection })

    @game.runner = @server.runner
  end

  it "loads a word" do
    expect(@game.word.solved?).to eq false
  end

  it "is not over when its word is not solved" do
    expect(@game.over?).to eq false
  end

  it "is over when its word is solved" do
    @game.word.guess "f"
    @game.word.guess "u"
    @game.word.guess "n"
    expect(@game.over?).to eq true
  end

  it "adds players" do
    expect(@game.players.count).to eq 2
  end

  it "returns the players whose turn it is" do
    expect(@game.current_player).to eq @game.players.first
  end

  it "adds a game runner" do
    @game.runner = @server.runner

    expect(@game.runner).to eq @server.runner
  end

  describe "Taking a turn" do
    it "writes a message to take a turn when it is a player's turn" do
      expect(@bretts_connection).to receive(:puts).with "The word is ---"
      expect(@bretts_connection).to receive(:puts).with "It's your turn. Take a guess."
      allow(@bretts_connection).to receive(:gets).and_return "g\n"
      expect(@bretts_connection).to receive(:puts).with "You guessed g."
      expect(@bretts_connection).to receive(:puts).with "Letters guessed: g"
      expect(@coreys_connection).to receive(:puts).with "The word is ---"
      expect(@coreys_connection).to receive(:puts).with "Brett guessed g."
      expect(@coreys_connection).to receive(:puts).with "Letters guessed: g"

      @game.take_turn
    end

    it "accepts a guess from the current player" do
      expect(@bretts_connection).to receive(:puts).with "The word is ---"
      expect(@bretts_connection).to receive(:puts).with "It's your turn. Take a guess."
      allow(@bretts_connection).to receive(:gets).and_return "g\n"
      expect(@bretts_connection).to receive(:puts).with "You guessed g."
      expect(@bretts_connection).to receive(:puts).with "Letters guessed: g"

      expect(@coreys_connection).to receive(:puts).with "The word is ---"
      expect(@coreys_connection).to receive(:puts).with "Brett guessed g."
      expect(@coreys_connection).to receive(:puts).with "Letters guessed: g"

      @game.take_turn
      expect(@game.guesses).to include "g"
    end

    it "re-prompts for a guess if the guess is too short" do
      expect(@bretts_connection).to receive(:puts).with "The word is ---"
      expect(@bretts_connection).to receive(:puts).with "It's your turn. Take a guess."
      allow(@bretts_connection).to receive(:gets).ordered.and_return "\n", "g\n"
      expect(@bretts_connection).to receive(:puts).with "Guess must be a single letter. Try again."

      expect(@bretts_connection).to receive(:puts).with "You guessed g."
      expect(@bretts_connection).to receive(:puts).with "Letters guessed: g"

      expect(@coreys_connection).to receive(:puts).with "The word is ---"
      expect(@coreys_connection).to receive(:puts).with "Brett guessed g."
      expect(@coreys_connection).to receive(:puts).with "Letters guessed: g"

      @game.take_turn
    end

    it "re-prompts for a guess if the guess is too long" do
      expect(@bretts_connection).to receive(:puts).with "The word is ---"
      expect(@bretts_connection).to receive(:puts).with "It's your turn. Take a guess."
      allow(@bretts_connection).to receive(:gets).ordered.and_return "ga\n", "g\n"
      expect(@bretts_connection).to receive(:puts).with "Guess must be a single letter. Try again."

      expect(@bretts_connection).to receive(:puts).with "You guessed g."
      expect(@bretts_connection).to receive(:puts).with "Letters guessed: g"

      expect(@coreys_connection).to receive(:puts).with "The word is ---"
      expect(@coreys_connection).to receive(:puts).with "Brett guessed g."
      expect(@coreys_connection).to receive(:puts).with "Letters guessed: g"

      @game.take_turn
    end

    it "switches turns for the next player" do
      expect(@bretts_connection).to receive(:puts).with "The word is ---"
      expect(@bretts_connection).to receive(:puts).with "It's your turn. Take a guess."
      expect(@bretts_connection).to receive(:puts).with "You guessed g."
      expect(@bretts_connection).to receive(:puts).with "Letters guessed: g"

      expect(@coreys_connection).to receive(:puts).with "The word is ---"
      expect(@coreys_connection).to receive(:puts).with "Brett guessed g."
      expect(@coreys_connection).to receive(:puts).with "Letters guessed: g"
      allow(@bretts_connection).to receive(:gets).and_return "g\n"
      @game.take_turn

      expect(@coreys_connection).to receive(:puts).with "The word is ---"
      expect(@coreys_connection).to receive(:puts).with "It's your turn. Take a guess."
      allow(@coreys_connection).to receive(:gets).and_return "a\n"
      expect(@coreys_connection).to receive(:puts).with "You guessed a."
      expect(@coreys_connection).to receive(:puts).with "Letters guessed: g, a"

      expect(@bretts_connection).to receive(:puts).with "The word is ---"
      expect(@bretts_connection).to receive(:puts).with "Corey guessed a."
      expect(@bretts_connection).to receive(:puts).with "Letters guessed: g, a"
      @game.take_turn

      expect(@game.guesses).to include "g"
      expect(@game.guesses).to include "a"
    end

    it "re-prompts for a guess if the letter has already been guessed" do
      expect(@bretts_connection).to receive(:puts).with "The word is ---"
      expect(@bretts_connection).to receive(:puts).with "It's your turn. Take a guess."
      expect(@bretts_connection).to receive(:puts).with "You guessed g."
      expect(@bretts_connection).to receive(:puts).with "Letters guessed: g"

      expect(@coreys_connection).to receive(:puts).with "The word is ---"
      expect(@coreys_connection).to receive(:puts).with "Brett guessed g."
      expect(@coreys_connection).to receive(:puts).with "Letters guessed: g"
      allow(@bretts_connection).to receive(:gets).and_return "g\n"
      @game.take_turn

      expect(@coreys_connection).to receive(:puts).with "The word is ---"
      expect(@coreys_connection).to receive(:puts).with "It's your turn. Take a guess."
      allow(@coreys_connection).to receive(:gets).and_return "g\n", "a\n"
      expect(@coreys_connection).to receive(:puts).with "Letter has already been guessed. Try again."
      expect(@coreys_connection).to receive(:puts).with "You guessed a."
      expect(@coreys_connection).to receive(:puts).with "Letters guessed: g, a"

      expect(@bretts_connection).to receive(:puts).with "The word is ---"
      expect(@bretts_connection).to receive(:puts).with "Corey guessed a."
      expect(@bretts_connection).to receive(:puts).with "Letters guessed: g, a"
      @game.take_turn

      expect(@game.guesses).to include "g"
      expect(@game.guesses).to include "a"
    end
  end

  describe "Play" do
    before(:each) do
      allow(@bretts_connection).to receive(:gets).and_return "f\n", "n\n"
      allow(@coreys_connection).to receive(:gets).and_return "u\n"
    end

    it "continues until the word has been solved" do
      @game.play

      expect(@game.over?).to be true
    end

    it "notifies players of the winner" do
      expect(@bretts_connection).to receive(:puts).with "The word is ---"
      expect(@bretts_connection).to receive(:puts).with "It's your turn. Take a guess."
      expect(@bretts_connection).to receive(:puts).with "You guessed f."
      expect(@bretts_connection).to receive(:puts).with "Letters guessed: f"
      expect(@coreys_connection).to receive(:puts).with "The word is ---"
      expect(@coreys_connection).to receive(:puts).with "Brett guessed f."
      expect(@coreys_connection).to receive(:puts).with "Letters guessed: f"

      expect(@coreys_connection).to receive(:puts).with "The word is f--"
      expect(@coreys_connection).to receive(:puts).with "It's your turn. Take a guess."
      expect(@coreys_connection).to receive(:puts).with "You guessed u."
      expect(@coreys_connection).to receive(:puts).with "Letters guessed: f, u"
      expect(@bretts_connection).to receive(:puts).with "The word is f--"
      expect(@bretts_connection).to receive(:puts).with "Corey guessed u."
      expect(@bretts_connection).to receive(:puts).with "Letters guessed: f, u"

      expect(@bretts_connection).to receive(:puts).with "The word is fu-"
      expect(@bretts_connection).to receive(:puts).with "It's your turn. Take a guess."
      expect(@bretts_connection).to receive(:puts).with "You guessed n."
      expect(@bretts_connection).to receive(:puts).with "Letters guessed: f, u, n"
      expect(@coreys_connection).to receive(:puts).with "The word is fu-"
      expect(@coreys_connection).to receive(:puts).with "Brett guessed n."
      expect(@coreys_connection).to receive(:puts).with "Letters guessed: f, u, n"

      expect(@bretts_connection).to receive(:puts).with "Game over. The word was 'fun'. Brett wins."
      expect(@coreys_connection).to receive(:puts).with "Game over. The word was 'fun'. Brett wins."

      @game.play
    end
  end
end
