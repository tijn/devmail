require "socket"
require "./log"

# This class starts a generic server, accepting multiple connections on the given port
#
# It reads the first word of the input and passes it to a handler (uppercased)
# e.g. QUIT or LIST
class GenericServer
  def initialize(@port : Int32)
    @server = TCPServer.new(@port)

    # Try to increase the buffer to give us some more time to parse incoming data
    # begin
    #   server.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVBUF, 1024 * 1024)
    # rescue
    #   # then try it using our available buffer
    # end
  end

  # Accept connections in separate fibers so we can handle multiple concurrent connections
  def run
    LOG.info "#{self.class} listening on port #{@port}"
    spawn do
      loop do
        spawn handle_session(@server.accept)
      end
    end
  end

  def session_handler(client)
    self
  end

  def handle_session(client)
    handler = session_handler(client)

    client_addr = client.remote_address
    LOG.info "#{self.class} connection #{client.object_id} from #{client_addr} accepted"
    handler.greet

    # Keep processing commands until somebody closes the connection
    while true
      input = client.gets
      # The first word of a line should contain the command
      command = input.to_s.split(' ', 2).first.upcase.strip
      LOG.debug "#{self.class} #{client.object_id} < #{input}"
      handler.process_command(command, input)
      break if client.closed?
    end
    LOG.info "#{self.class} connection #{client.object_id} from #{client_addr} closed"
  rescue ex
    LOG.error "#{self.class} #{client.object_id} ! #{ex}"
    client.close
  end
end
