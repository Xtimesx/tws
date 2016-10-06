require './mnt'
require './twitter_patches'
require 'tweetstream'
require './config'
require './speak'
require 'net/http'
require "observer"
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
  download status
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

#def download(status)
#  threads = []
#  threads << Thread.new(status) do |status|
#    status.media.each do |m|
#      m.download(folder: status.id.to_s);
#      m.save;
#      Thread.current[:path] = "file://#{File.expand_path(m.file_path)}"
#    end
#  end
#  download_to_asset_server(status)
#end

def download(status)
  threads = []
  status.media.each do |m|
    threads << Thread.new(status) do |status|
      uniq_name= "#{status.retweeted? ? status.retweeted_status.id : status.id}/#{m.file_name}"
      uri = URI("http://127.0.0.1:8080")
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Post.new uri
        media_uri = case m
          when Twitter::Media::Video
            m[:video_info][:variants].select{|v| v[:content_type] == 'video/mp4'}.sort{|b,a| a[:bitrate] <=> b[:bitrate]}.first[:url]
          else
            m.media_uri
          end
        request.body = "{ \"job_iD\": #{rand(2**30)}, \"uniq_name\": \"#{uniq_name}\", \"src\": \"#{media_uri}\" }"
        response = http.request request # Net::HTTPResponse object
        Thread.current[:code] = response.code
      end
      Thread.current[:uri] = uri.to_s + '/' + uniq_name
      Thread.current[:path] = "file://#{File.expand_path("./assets/image/#{uniq_name}")}"
    end
  end

  threads.each do |t|
    t.join
    puts "#{t[:code]} for: #{t[:path]}"
  end
end

def show(status, options= {})
  msg = ['']
  case status.class.name
  when 'Twitter::Tweet'
    msg << (puts status.full_text.gsub('&gt;','>').gsub('&lt;','<').gsub('&amp;','&') )
    say(status.full_text, {lang: status.lang, voice: voiceForUserByName(status.user.screen_name) }) unless status.retweet? || !@speak
  when 'Twitter::User'
    msg << (puts "#{status.screen_name}/#{status.name}: #{voiceForUserByName(status.screen_name)}")
    msg << (puts status.description)
    msg << (puts status.location)
  else
    puts status.class.name
    status.inspect
  end
  msg.join("\r\n")
end

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
    client.userstream
  rescue
    puts "Durr!: #{$!}"
    sleep 5
    retry
  end
end
