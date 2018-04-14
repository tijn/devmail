require "./session"

class POPSession < Session
  def initialize(client : TCPSocket, @store : Store)
    super(client)
    @store = store
  end

  # Send a greeting to client
  def greet
    @store.truncate
    respond(true, "Hello there")
  end

  # Process command
  def process_command(command : String, full_data : String)
    case command
    when "CAPA" then capa
    when "DELE" then dele(message_number(full_data))
    when "LIST" then list(message_number(full_data))
    when "NOOP" then respond(true, "Yup.")
    when "PASS" then pass(full_data)
    when "QUIT" then quit
    when "RETR" then retr(message_number(full_data))
    when "RSET" then respond(true, "Resurrected.")
    when "STAT" then stat
    when "TOP"  then top(full_data)
    when "UIDL" then uidl(message_number(full_data))
    when "USER" then user(full_data)
    else
      respond(false, "Invalid command.")
    end
  end

  # Show the client what we can do
  def capa
    respond(true, "Here's what I can do:\r\nUSER\r\nIMPLEMENTATION Post Office POP3 Server\r\n.")
  end

  # Accept username
  def user(full_data)
    respond(true, "Password required.")
  end

  # Authenticate client
  def pass(full_data)
    respond(true, "Logged in.")
  end

  # Show list of messages
  #
  # When a message ID is specified only list the size of that message
  def list(message_id)
    if message_id.is_a? Int
      size = @store.size(message_id)
      respond(true, "#{message_id} #{size}")
    elsif message_id == :invalid
      respond(false, "Invalid message number.")
    elsif message_id == :all
      messages = ""
      @store.each_index do |index|
        size = @store.size(index)
        messages = messages + "#{index} #{size}\r\n"
      end
      respond(true, "POP3 clients that break here violate STD53.\r\n#{messages}.")
    else
      # raise error
    end
  end

  # Retreives message
  def retr(message_id)
    if message_id.is_a? Int
      message_data = @store.get(message_id).to_s
      respond(true, "#{message_data.size} octets to follow.\r\n" + message_data + "\r\n.")
    elsif message_id == :invalid
      respond(false, "Invalid message number.")
    elsif message_id == :all
      respond(false, "Invalid message number.")
    else
      # raise error
    end
  end

  # Shows list of message uid
  #
  # When a message id is specified only list
  # the uid of that message
  def uidl(message_id)
    if message_id.is_a? Int
      message_data = @store.get(message_id).to_s
      respond(true, "#{message_id} #{message_uid(message_data)}")
    elsif message_id == :invalid
      respond(false, "Invalid message number.")
    elsif message_id == :all
      messages = ""
      @store.each_index do |index|
        message = @store.get(index).to_s
        uid = message_uid(message)
        messages = messages + "#{index} #{uid}\r\n"
      end
      respond(true, "unique-id listing follows.\r\n#{messages}.")
    else
      # raise error
    end
  end

  # Shows total number of messages and size
  def stat
    respond(true, "#{@store.count} #{@store.total_size}")
  end

  # Display headers of message
  def top(full_data)
    full_data = full_data.split(/TOP\s(\d*)/)
    messagenum = full_data[1].to_i
    number_of_lines = full_data[2].to_i

    messages = @store.messages
    if messages.size >= messagenum && messagenum > 0
      headers = ""
      line_number = -2
      messages[messagenum - 1].to_s.split(/\r\n/).each do |line|
        line_number = line_number + 1 if line.gsub(/\r\n/, "") == "" || line_number > -2
        headers += "#{line}\r\n" if line_number < number_of_lines
      end
      respond(true, "headers follow.\r\n" + headers + "\r\n.")
    else
      respond(false, "Invalid message number.")
    end
  end

  # Quits
  def quit
    respond(true, "Better luck next time.")
    @client.close
  end

  # Deletes message
  def dele(message : Symbol | Int)
    if message.is_a?(Int)
      @store.remove(message)
      respond(true, "Message deleted.")
    else
      respond(false, "Invalid message number.")
    end
  end

  # protected

  # Returns message number parsed from full_data:
  #
  # * No message number => :all
  # * Message does not exists => :invalid
  # * valid message number => some fixnum
  def message_number(full_data)
    if /\w*\s*\d/ =~ full_data
      messagenum = full_data.gsub(/\D/, "").to_i
      messages = @store.messages
      if messages.size >= messagenum && messagenum > 0
        return messagenum
      else
        return :invalid
      end
    else
      return :all
    end
  end

  # Respond to client with a POP3 prefix (+OK or -ERR)
  def respond(status : Bool, message : String)
    super("#{status ? "+OK" : "-ERR"} #{message}\r\n")
  end

  def message_uid(message : String)
    Digest::SHA1.hexdigest(message)
  end
end
