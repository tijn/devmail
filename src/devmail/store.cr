# Message storage
class Store
  def initialize
    @messages = [] of String | Nil
  end

  def messages
    @messages
  end

  # Returns array of messages
  def get(index)
    @messages[index - 1]
  end

  def size(index)
    message = get(index)
    if message.is_a? Nil
      0
    else
      message.size
    end
  end

  def total_size
    @messages.map { |m| m.to_s.size }.sum
  end

  # Saves message in storage
  def add(_mail_from, _rcpt_to, message_data)
    @messages.push(message_data)
  end

  # Removes message from storage
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
