require './mnt'
require './twitter_patches'
require 'tweetstream'
require './config'
require './speak'
require 'net/http'
require "observer"
require './downloader'
#require 'rack/stream'
#use Rack::Stream
class ObservableMessage
  include Observable

  def initialize(msg)
    @message = msg
  end

  def push(message)
    @message = message
    changed
    notify_observers(message)
  end

  def message
    @message
  end
end
@speak = !!ENV["TALK"]
#class App
#  include Rack::Stream::DSL
#
#  def initialize(msg)
#    @msg = msg
#    msg.add_observer(self)
#  end
#
#  def update(msg)
#    @msg = msg
#  end
#
#  stream do
#    after_open do
#      count = 0
#      @timer = EM.add_periodic_timer(1) do
#        if msg.changed?
#          chunk msg.message
#        end
#      end
#    end
#
#    before_close do
#      @timer.cancel
#      chunk "bye!\n"
#    end
#
#    [200, {'Content-Type' => 'text/plain'}, []]
#  end
#end

message = ObservableMessage.new("Hello")

client = TweetStream::Client.new

client.on_error do |message|
  puts message
end

client.on_direct_message do |direct_message|
  puts
  puts direct_message.full_text
end


client.on_timeline_status do |status|
  if defined? Tws && defined? Tws::StatusDownloader
    puts Tws::StatusDownloader.download status
  end
  puts "#" * @cols
  status.save
  message.push(show_with_context(status, depth: 10))
end

#client.sitestream([2263321928], :followings => true) do |status|
#  puts "#" * @cols#

#  download status
#  status.save
#  #puts "saved"
#  show_with_context status, depth: 10
#end



def show_with_context(status, options= {})
  msg = ['']
  context = status.load_context depth: 10
  context.each do |tweet|
    msg << show(tweet)
    puts "~" * @cols
  end
  msg
end

#system("./serv &")
while true do
  begin
    puts "run client"
    client.userstream
  rescue
    puts "Durr!: #{$!}"
    sleep 5
    retry
  end
end
