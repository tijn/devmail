require "http/server"

class HTTPServer
  # class MailboxController
  #   include Routing::Routable

  #   def method1
  #     HTTP::Response.ok "text/plain", "method1"
  #   end

  #   def method2
  #     HTTP::Response.ok "text/plain", routing_context.params["id"]
  #   end
  # end

  # class Routes
  #   include Routing::HttpRequestRouter

  #   get "/", "mailbox#index"
  #   get "/:id", "mailbox#show"
  #   root "mailbox#index"
  # end

  def initialize(@store : Store, @port = 80)
  end

  def run
    server = HTTP::Server.new do |context|
      handle_request(context)
    end
    address = server.bind_tcp "0.0.0.0", @port
    puts "Listening on http://#{address}"
    server.listen
  end

  def handle_request(context)
    context.response.content_type = "text/plain"
    context.response.print "Hello world!"
  end
end
