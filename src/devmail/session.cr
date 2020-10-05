require "./log"

class Session
  def initialize(@client : TCPSocket)
  end

  # Send a greeting to client
  def greet
    respond(220)
  end

  def process_command(command : String, full_data : String)
    Log.debug { "#{@client.object_id} < command=<#{command}> #{full_data}" }
  end

  # Respond to client by sending back text
  def respond(text : String)
    Log.debug { "#{@client.object_id} > #{text}" }
    @client.write text.to_s.to_slice
  rescue ex
    Log.error { "#{@client.object_id} ! #{ex}" }
    @client.close
  end
end
