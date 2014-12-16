module Hangman
  class Server
    attr_accessor :game, :connections, :runner

    def initialize(options={})
      @game        = options[:game] || Game.new
      @connections = Connections.new
      @runner      = Runner.new(connections: connections)
    end

    def add_connection(connection)
      connection[:name] = connection[:name].downcase
      game.players << connection
      player = game.players.select { |p| p.name == connection[:name] }.first
      connections << { :player => player, :connection => connection[:connection] }
    end
  end
end
