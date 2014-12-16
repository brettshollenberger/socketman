require "spec_helper"

describe Hangman::Server::Runner do
  before(:each) do
    @server            = Hangman::Server.new
    @bretts_connection = StringIO.new
    @coreys_connection = StringIO.new

    @server.add_connection({ :name => "Brett", :connection => @bretts_connection })
    @server.add_connection({ :name => "Corey", :connection => @coreys_connection })
  end

  it "writes out to connections" do
    @server.runner.write(@server.game.players.first, "Hello")

    @bretts_connection.rewind
    expect(@bretts_connection.gets.chomp).to eq "Hello"
  end

  it "reads in from connections" do
    allow(@bretts_connection).to receive(:gets).and_return("Hello\n")

    expect(@server.runner.read(@server.game.players.first)).to eq "Hello"
  end
end
