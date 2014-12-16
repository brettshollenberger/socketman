require "socket"
require "pry"
require "pry-byebug"

connection_acceptor = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
address = Socket.pack_sockaddr_in(3000, "0.0.0.0")

# open socket on localhost:3000
connection_acceptor.bind(address)

# accept a queue of up to 10 requests to open a socket
connection_acceptor.listen(10)

trap "EXIT" do
  puts "Closing connection"
  connection_acceptor.close
end

trap "INT" do
  exit
end

module Hangman
  class Game
    attr_accessor :players, :connections, :revealed_word, :word, :guessed

    def initialize
      @players       = []
      @connections   = {}
      @revealed_word = "---"
      @word          = "fun"
      @guessed       = []
      @turn          = 0
    end

    def turn
      @turn
    end

    def turn=(n)
      @turn = n
    end

    def over?
      revealed_word == word
    end

    def start
      puts "Game started!"

      connections.each do |player, connection|
        connection.puts "Game started"
      end

      until over?
        prompt_player
      end

      fineto
    end

    def fineto
      connections.each do |player, connection|
        connection.puts "Game over"
      end
    end

    def prompt_player
      unless players[self.turn].nil?
        active_player     = players[self.turn]
        active_connection = connections[active_player]

        active_connection.puts "The word is #{revealed_word}"
        active_connection.puts "The letters guessed are #{guessed.join(',')}"
        active_connection.puts "Guess a letter."

        letter = active_connection.gets.chomp.downcase

        guess_letter(letter)
        notify_players(active_player, letter)
        self.turn += 1
      else
        self.turn = 0
        prompt_player
      end
    end

    def guess_letter(letter)
      guessed << letter

      word.chars.each_with_index do |word_letter, index|
        if letter == word_letter
          revealed_word[index] = letter
        end
      end
    end

    def notify_players(active_player, letter)
      connections.each do |player, connection|
        if active_player == player
          connection.puts "You guessed #{letter}."
          connection.puts "The word is now #{revealed_word}"
        else
          connection.puts "#{active_player} guessed #{letter}"
          connection.puts "The word is now #{revealed_word}"
        end
      end
    end
  end
end

game = Hangman::Game.new

read, write = IO.pipe
threads     = []

2.times do
  threads << Thread.start do
    loop do
      socket, addr = connection_acceptor.accept

      player_name = socket.gets.chomp

      puts "Player #{player_name} joined!"

      game.players << player_name.to_sym

      game.connections[player_name.to_sym] = socket

      threads << Thread.start do
        socket.gets

        puts "Start receieved"

        write.puts "Start game"

        puts "Wrote start game"

        self
      end

      puts "Opening another prefork loop"
    end

    self
  end
end

start = read.gets
puts "Parent got #{start}"
read.close
write.close

threads.each do |thread|
  Thread.kill thread
end

game.start
