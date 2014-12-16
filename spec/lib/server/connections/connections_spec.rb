require "spec_helper"

describe Hangman::Server::Connections do
  before(:each) do
    @server              = Hangman::Server.new
    @mock_tcp_connection = Support::Mocks::TCPSocket.new
    @server.add_connection({ :name => "Brett", :connection => @mock_tcp_connection })
  end

  it "adds connections" do
    expect(@server.connections.brett.connection).to eq @mock_tcp_connection
  end

  it "enumerates connections" do
    expect(@server.connections.map { |c| c.connection }.first).to eq @mock_tcp_connection
  end
end
