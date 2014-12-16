require "spec_helper"

describe Hangman::Game::Players do
  before(:each) do
    @game = Hangman::Game.new
  end

  it "adds players" do
    @game.players << { :name => "Brett" }

    expect(@game.players.first.class).to eq Hangman::Game::Player
  end
end
