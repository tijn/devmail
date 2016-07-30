require "ini"

class Config
  def initialize(@options : Hash(String, Hash(String, String)) = {} of String => Hash(String, String))
  end

  def self.load(filename)
    new INI.parse File.read(filename)
  end

  def self.load_first(filenames : Array(String))
    first = filenames.find { |filename| File.exists? filename }
    if first.nil?
      new
    else
      load first
    end
  end

  def general
    @options.fetch("general", {} of String => String)
  end
end
