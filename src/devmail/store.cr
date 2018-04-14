# Message storage
# This is basically a wrapper around Array to support the API used by POP and SMTP.
class Store
  def initialize
    @messages = [] of String | Nil
  end

  def messages
    @messages
  end

  def get(index)
    @messages[index - 1]
  end

  # message size
  def size(index)
    message = get(index)
    if message.is_a? Nil
      0
    else
      message.size
    end
  end

  # total size of all messages
  def total_size
    @messages.map { |m| m.to_s.size }.sum
  end

  # Save message in storage
  def add(_mail_from, _rcpt_to, message_data)
    @messages.push(message_data)
  end

  # Remove message from storage
  def remove(index)
    @messages[index - 1] = nil
  end

  # Remove empty messages
  def truncate
    @messages.compact!
  end

  def each_index
    @messages.each_index { |i| yield i + 1 }
  end

  def count
    @messages.size
  end
end
