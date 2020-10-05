require "log"

struct ExtraShort < Log::StaticFormatter
  def run
    message
  end
end
