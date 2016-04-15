require './mnt'
require './twitter_patches'
require 'tweetstream'
require './config'
require './speak'
require 'net/http'


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
  #puts "saved"
  show_with_context status, depth: 10
end


#client.sitestream([2263321928], :followings => true) do |status|
#  puts "#" * @cols#

#  download status
#  status.save
#  #puts "saved"
#  show_with_context status, depth: 10
#end

def download(status)
  status.media.each do |m|
    m.download(folder: status.id.to_s);
    m.save; 
    puts "file://#{File.expand_path(m.file_path)}" 
  end
  download_to_asset_server(status)
end

def download_to_asset_server(status)
  status.media.each do |m|
    uniq_name= "#{status.id}/#{m.file_name}"
    uri = URI("http://127.0.0.1:8080")
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Post.new uri
      request.body = "{ \"job_iD\": #{rand(2**30)}, \"uniq_name\": \"#{uniq_name}\", \"src\": \"#{m.media_uri}\" }"
      response = http.request request # Net::HTTPResponse object
      puts "upload done: #{response.code}"
      puts uri.to_s + '/' + uniq_name
    end
  end
end

def show(status, options= {})
  case status.class.name
  when 'Twitter::Tweet'
    puts status.full_text
    say(status.full_text, {lang: status.lang, voice: voiceForUserByName(status.user.screen_name) }) unless status.retweet?
  when 'Twitter::User'
    puts "#{status.screen_name}/#{status.name}: #{voiceForUserByName(status.screen_name)}"
    puts status.description
    puts status.location
   # puts status.inspect
  else
    puts status.class.name
    status.inspect
  end
end

def show_with_context(status, options= {})
  context = status.load_context depth: 10
  context.each do |tweet|
    show tweet
    puts "~" * @cols
  end

end

puts "init complete"
run = true
while run do
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
