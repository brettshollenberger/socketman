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
      expect(@coreys_connection).to receive(:puts).with "It's Brett's turn"
      expect(@coreys_connection).to receive(:puts).with "Brett guessed f."
      expect(@coreys_connection).to receive(:puts).with "Letters guessed: f"

      expect(@coreys_connection).to receive(:puts).with "The word is f--"
      expect(@coreys_connection).to receive(:puts).with "It's your turn. Take a guess."
      expect(@coreys_connection).to receive(:puts).with "You guessed u."
      expect(@coreys_connection).to receive(:puts).with "Letters guessed: f, u"
      expect(@bretts_connection).to receive(:puts).with "The word is f--"
      expect(@bretts_connection).to receive(:puts).with "It's Corey's turn"
      expect(@bretts_connection).to receive(:puts).with "Corey guessed u."
      expect(@bretts_connection).to receive(:puts).with "Letters guessed: f, u"

      expect(@bretts_connection).to receive(:puts).with "The word is fu-"
      expect(@bretts_connection).to receive(:puts).with "It's your turn. Take a guess."
      expect(@bretts_connection).to receive(:puts).with "You guessed n."
      expect(@bretts_connection).to receive(:puts).with "Letters guessed: f, u, n"
      expect(@coreys_connection).to receive(:puts).with "The word is fu-"
      expect(@coreys_connection).to receive(:puts).with "It's Brett's turn"
      expect(@coreys_connection).to receive(:puts).with "Brett guessed n."
      expect(@coreys_connection).to receive(:puts).with "Letters guessed: f, u, n"

      expect(@bretts_connection).to receive(:puts).with "Game over. The word was 'fun'. Brett wins."
      expect(@coreys_connection).to receive(:puts).with "Game over. The word was 'fun'. Brett wins."

      @game.play
    end
  end
end
