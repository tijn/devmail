require "./generic_server"
require "./store"
require "./smtp_session"

# This class is just a copy of POPServer; the only difference being the session handler they instantiate
# I should just inject the session handler creation method somehow. Maybe with a block passed to the
# initializer or to #run?
class SMTPServer < GenericServer
  def initialize(@store : Store, port = 25)
    super(port)
  end

  def session_handler(client)
    SMTPSession.new(client, @store)
  end
end
