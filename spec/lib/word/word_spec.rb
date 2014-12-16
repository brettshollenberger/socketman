require "spec_helper"

describe Hangman::Word do
  before(:each) do
    @word = Hangman::Word.new
  end

  it "loads a secret word" do
    expect(@word.secret.scan(/\w+/).count).to eq 1
  end

  it "has the value of its secret word dashed" do
    expect(@word).to eq @word.secret.gsub(/\w/) { |letter| "-" }
  end

  it "guesses letters" do
    @word = Hangman::Word.new(:secret => "fun")
    @word.guess "f"

    expect(@word).to eq "f--"
  end

  it "downcases letters received" do
    @word = Hangman::Word.new(:secret => "fun")
    @word.guess "F"

    expect(@word).to eq "f--"
  end

  it "throws if multiple letters are guessed" do
    @word = Hangman::Word.new(:secret => "fun")
    expect { @word.guess "fu" }.to raise_error Hangman::Word::InvalidGuessError
  end

  it "is not solved when its value is not equal to its secret value" do
    @word = Hangman::Word.new(:secret => "fun")
    @word.guess "f"
    @word.guess "u"

    expect(@word.solved?).to be false
  end

  it "is solved when its value equals its secret value" do
    @word = Hangman::Word.new(:secret => "fun")
    @word.guess "f"
    @word.guess "u"
    @word.guess "n"

    expect(@word.solved?).to be true
  end
end
