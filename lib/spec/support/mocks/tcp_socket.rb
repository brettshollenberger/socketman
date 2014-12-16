require "socket"

module Support
  module Mocks
    class TCPSocket
      def readline(some_text = nil)
        return @canned_response
      end

      def flush
      end

      def write(some_text = nil)
      end

      def readchar
        return 6
      end

      def read(num)
        return num > @canned_response.size ? @canned_response : @canned_response[0..num]
      end

      def set_canned(response)
        @canned_response = response
      end
    end

    def mock_tcp_next_request(string)
      TCPSocket.stub!(:new).and_return {
        cm = FakeTCPSocket.new
        cm.set_canned(string)
        cm
      }
    end
  end
end
