require "./session"

class SMTPSession < Session
  # Standard SMTP response codes
  RESPONSES = {
    211 => "System status, or system help respond",
    214 => "Help message",
    220 => "Post Office Service ready",
    221 => "Post Office Service closing transmission channel",
    250 => "Requested mail action okay, completed",
    251 => "User not local; will forward to <forward-path>",
    354 => "Start mail input; end with <CRLF>.<CRLF>",
    421 => "Post Office Service not available,",
    450 => "Requested mail action not taken: mailbox unavailable",
    451 => "Requested action aborted: error in processing",
    452 => "Requested action not taken: insufficient system storage",
    500 => "Syntax error, command unrecognized",
    501 => "Syntax error in parameters or arguments",
    502 => "Command not implemented",
    503 => "Bad sequence of commands",
    504 => "Command parameter not implemented",
    550 => "Requested action not taken: mailbox unavailable",
    551 => "User not local; please try <forward-path>",
    552 => "Requested mail action aborted: exceeded storage allocation",
    553 => "Requested action not taken: mailbox name not allowed",
    554 => "Transaction failed",
  }

  def initialize(client : TCPSocket, @store : Store)
    super(client)

    # rset
    @from = ""
    @to = ""
    @data = ""
    @sending_data = false
  end

  def process_command(command, full_data)
    case command
    when "DATA"         then data
    when "HELO", "EHLO" then respond(250)
    when "NOOP"         then respond(250)
    when "MAIL"         then mail_from(full_data.to_s)
    when "QUIT"         then quit
    when "RCPT"         then rcpt_to(full_data.to_s)
    when "RSET"         then rset
    else
      if @sending_data
        append_data(full_data.to_s)
      else
        respond(500)
      end
    end
  end

  # Send a greeting to client
  def greet
    respond(220)
  end

  # Close connection
  def quit
    respond(221)
    @client.close
  end

  # Store sender address
  def mail_from(full_data)
    if /^MAIL FROM:/ =~ full_data.upcase
      @from = full_data.gsub(/^MAIL FROM:\s*/i, "").gsub(/[\r\n]/, "")
      respond(250)
    else
      respond(500)
    end
  end

  # Store recepient address
  def rcpt_to(full_data)
    if /^RCPT TO:/ =~ full_data.upcase
      @to = full_data.gsub(/^RCPT TO:\s*/i, "").gsub(/[\r\n]/, "")
      respond(250)
    else
      respond(500)
    end
  end

  # Mark client sending data
  def data
    @sending_data = true
    @data = ""
    respond(354)
  end

  # Reset current session
  def rset
    @from = ""
    @to = ""
    @data = ""
    @sending_data = false
  end

  # Append data to incoming mail message
  #
  # full_data == "." indicates the end of the message
  def append_data(full_data : String)
    if full_data.gsub(/[\r\n]/, "") == "."
      @store.add(@from, @to, @data.to_s)
      respond(250)
      LOG.info "Received mail from #{@from} to #{@to}"
    else
      @data = @data + full_data
    end
  end

  # Respond with a standard SMTP response code
  def respond(code : Int)
    super("#{code} #{RESPONSES[code]}\r\n")
  end
end
