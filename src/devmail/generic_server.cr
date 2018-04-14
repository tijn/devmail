require "socket"
require "./log"

# This class starts a generic server, accepting multiple connections on the given port.
#
# It is written to support a specific (but common) type of server that accepts lines that look like this:
#     <COMMAND> [<PAYLOAD>]
# It reads the first word of the input, the command (e.g. QUIT or LIST) and passes it to a handler together with the payload. It will uppercase the command so that a session handler can ignore upper/lower case when  processing commands.
class GenericServer
  def initialize(@port : Int32)
    @server = TCPServer.new(@port)
  end

  def run
    LOG.info "#{self.class} listening on port #{@port}"
    # Accept connections in separate fibers so we can handle multiple concurrent connections
    spawn do
      loop do
        spawn handle_session(@server.accept)
      end
    end
  end

  def build_session_handler(client)
    Session.new(client)
  end

  def handle_session(client)
    handler = build_session_handler(client)

    client_addr = client.remote_address
    connection_id = client.object_id
    LOG.info "#{self.class} connection #{connection_id} from #{client_addr} accepted"
    handler.greet

    # Keep processing commands until somebody closes the connection
    while true
      break if client.closed?

      input = client.gets(false)
      next if input.nil?

      # The first word of a line should contain the command
      input = input.to_s
      command = input.split(' ', 2).first.upcase.strip
      LOG.debug "#{self.class} connection #{connection_id} < #{input}"
      handler.process_command(command, input)
    end
    LOG.info "#{self.class} connection #{connection_id} from #{client_addr} closed"
  rescue ex
    LOG.error "#{self.class} #{connection_id} ! #{ex}"
    client.close
  end
end
