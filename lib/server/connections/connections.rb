require "ostruct"

module Hangman
  class Server
    class Connections < OpenStruct
      include Enumerable

      def <<(connection)
        send("#{connection[:player].name.downcase}=", Hangman::Server::Connection.new(connection))
      end

      def each(&block)
        self.methods(false).reject { |k| k.to_s.match(/\=/) }.map do |connection_name|
          self.send(connection_name)
        end
      end

      def map(&block)
        each.map(&block)
      end
    end
  end
end
