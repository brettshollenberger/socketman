require "socket"

module Hangman
  class Server
    attr_accessor :connection_acceptor, :address, :game, :connections, :runner, :threads

    def initialize(options={})
      @game        = options[:game] || Game.new
      @connections = Connections.new
      @runner      = Runner.new(connections: connections)
      @game.runner = @runner
      @threads     = []
    end

    def add_connection(connection)
      connection[:name] = connection[:name].downcase
      game.players << connection
      player = game.players.select { |p| p.name == connection[:name] }.first
      connections << { :player => player, :connection => connection[:connection] }
    end

    def start
      create_socket
      notify_started
      open_io_pipe
      start_prefork_threads
      receive_start_command
      kill_threads
      game.play
    end

    def quit
      connection_acceptor.close
    end

  private
    def create_socket
      @connection_acceptor = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
      @address             = Socket.pack_sockaddr_in(3000, "0.0.0.0")

      connection_acceptor.bind(address)
      connection_acceptor.listen(10)
    end

    def notify_started
      puts "Server started on localhost:3000"
    end

    def open_io_pipe
      @read, @write = IO.pipe
    end

    def receive_start_command
      @read.gets
      @read.close
      @write.close
    end

    def kill_threads
      threads.each do |thread|
        Thread.kill thread
      end
    end

    def start_prefork_threads
      2.times do
        threads << Thread.start do
          loop do
            socket, addr = connection_acceptor.accept

            player_name = socket.gets.chomp

            puts "Player #{player_name} joined!"

            add_connection({ :name => player_name, :connection => socket })

            listen_for_game_start(socket)

            puts "Opening another prefork loop"
          end

          self
        end
      end
    end

    def listen_for_game_start(socket)
      threads << Thread.start do
        socket.gets
        puts "Start received"
        @write.puts "Start game"
        self
      end
    end
  end
end
