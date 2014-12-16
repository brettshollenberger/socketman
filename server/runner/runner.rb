module Hangman
  class Server
    class Runner
      attr_accessor :connections

      def initialize(options={})
        @connections = options[:connections]
      end

      def write(player, message)
        connection_for_player(player).puts message
      end

      def read(player)
        connection_for_player(player).gets.chomp
      end

    private
      def connection_for_player(player)
        connections.send(player.name.to_sym).connection
      end
    end
  end
end
