require "./generic_server"
require "./store"
require "digest/sha1"
require "./pop_session"

class POPServer < GenericServer
  def initialize(@store : Store, port = 110)
    super(port)
  end

  def build_session_handler(client)
    POPSession.new(client, @store)
  end
end
