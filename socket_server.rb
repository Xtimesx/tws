#!/usr/bin/env ruby -w
require "socket"
DB = {} #dummy
require "bunny"
require 'json'
require 'twitter'
require './twitter_patches'

# Copyright: Hiroshi Ichikawa <http://gimite.net/en/>
# Lincense: New BSD Lincense

#https://github.com/gimite/web-socket-ruby/blob/master/samples/chat_server.rb
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require "web_socket"
require "thread"

Thread.abort_on_exception = true

if ARGV.size != 2
  $stderr.puts("Usage: ruby sample/chat_server.rb ACCEPTED_DOMAIN PORT")
  exit(1)
end

server = WebSocketServer.new(
  :accepted_domains => [ARGV[0]],
  :port => ARGV[1].to_i())
puts("Server is running at port %d" % server.port)
connections = []

server.run() do |ws|
  begin
    
    puts("Connection accepted")
    ws.handshake()
    que = Queue.new()
    connections.push(que)
    
    thread = Thread.new() do
      while true
        message = que.pop()
        ws.send(message)
        puts("Sent: #{message}")
      end
    end

    @bunny = Bunny.new(:automatically_recover => false)
    @bunny.start

    ch_in  = @bunny.create_channel
    x = ch_in.topic("tweets")
    @q = ch_in.queue("", :exclusive => true)

    @q.bind(x, routing_key: '#')

    @q.subscribe(:block => true) do |delivery_info, properties, body|
      for conn in connections
        conn.push(body)
      end
    end
 
    while data = ws.receive()
      puts("Received: #{data}")

    end
    
  ensure
    connections.delete(que)
    thread.terminate() if thread
    puts("Connection closed")
  end
end
