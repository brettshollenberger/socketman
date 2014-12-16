require "socket"

class Client
  attr_accessor :server

  def initialize(options={})
    @server = options[:server]

    get_player_name
    request_loop
    response_loop
    @request.join
    @response.join
  end

  def get_player_name
    puts "What is your name?"
    server.puts gets.chomp
  end

  def request_loop
    @request = Thread.start do
      puts "Type anything to start"

      loop do
        msg = gets.chomp
        puts "You said #{msg}"
        server.puts msg
      end
    end
  end

  def response_loop
    @response = Thread.start do
      loop do
        msg = server.gets
        puts msg

        if msg.match(/Game over/)
          exit
        end
      end
    end
  end
end

server = TCPSocket.new("0.0.0.0", 3000)
client = Client.new(server: server)
