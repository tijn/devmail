require "./log"

class Session
  def initialize(@client : TCPSocket)
  end

  # Respond to client by sending back text
  def respond(text : String)
    LOG.debug "#{@client.object_id} > #{text}"
    @client.write text.to_s.to_slice
  rescue ex
    LOG.error "#{@client.object_id} ! #{ex}"
    @client.close
  end
end
