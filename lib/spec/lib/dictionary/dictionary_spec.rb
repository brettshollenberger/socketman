require "spec_helper"

describe Hangman::Dictionary do
  before(:each) do
    @dictionary = Hangman::Dictionary.new
  end

  it "samples a random word" do
    word = @dictionary.sample
    expect(word.scan(/\w+/).first).to eq word
  end
end
