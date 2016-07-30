require "option_parser"
require "logger"
require "./devmail/config"
require "./devmail/store"
require "./devmail/smtp_server"
require "./devmail/pop_server"

program = "devmail"

local = ENV.fetch("XDG_CONFIG_HOME", "~/.config") + "/#{program}/#{program}.ini"
global = "/etc/#{program}.ini"

options = Config.load_first([local, global]).general

verbose = options.fetch("verbose", false) == "true"
smtp_port = options.fetch("smtp_port", 25).to_i
pop3_port = options.fetch("pop3_port", 110).to_i

OptionParser.parse! do |parser|
  parser.banner = "Usage: #{program} [options]"

  parser.on("-h", "--help", "Display this screen") do
    puts parser
    exit
  end

  parser.on("-p PORT", "--pop3 PORT", "Specify POP3 port to use") do |port|
    pop3_port = port.to_i
  end

  parser.on("-s PORT", "--smtp PORT", "Specify SMTP port to use") do |port|
    smtp_port = port.to_i
  end

  parser.on("-v", "--verbose", "Output more information") do
    verbose = true
  end
end

$log = Logger.new(STDOUT)
$log.level = verbose ? Logger::DEBUG : Logger::INFO
# $log.datetime_format = "%H:%M:%S"

store = Store.new
smtp_server = SMTPServer.new(store, smtp_port)
pop_server = POPServer.new(store, pop3_port)

smtp_server.run
pop_server.run
sleep
