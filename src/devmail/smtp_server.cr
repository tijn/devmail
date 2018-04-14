require "./generic_server"
require "./store"
require "./smtp_session"

class SMTPServer < GenericServer
  def initialize(@store : Store, port = 25)
    super(port)
  end

  def build_session_handler(client)
    SMTPSession.new(client, @store)
  end
end
