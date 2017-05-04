require 'tweetstream'

TweetStream.configure do |config|
  config.consumer_key       = 'VYF97tIjMctKTXHV9OZzLvS0D'
  config.consumer_secret    = 'oACoadguMBkJMLydsWM5rjerXJcIcENVyAkOYOKTKXYKAEjP94'
  config.oauth_token        = '3055277621-hQAjtxe6lTOlMj0s2liRbckGKHZsLLIj1a6Lxvj'
  config.oauth_token_secret = 'sKI2eJbesRaAHalT9o3YXZ0Ns1cwnovnOyg7rQlhHACEG'
  config.auth_method        = :oauth
end

client = TweetStream::Client.new

client.on_timeline_status do |status|
  if status.retweet?
    #puts "~" * 160
    #puts status
    #puts status.methods - Object.methods
    #puts status.retweeted_status
    #puts status.retweeted_status.class.name
    #puts status.retweeted_status.to_hash
    #puts status.media.first#.to_hash.each{ |k,v| puts "#{v.class.name} :#{k} ##{v}" }
    #puts status.methods - Object.methods
    #puts "~" * 160
    status.to_hash.each{ |k,v| puts "#{v.class.name} :#{k} ##{v}" }
    #status.user.to_hash.each{ |k,v| puts "#{v.class.name} :#{k}##{v}" } if status.user.following?
    #status.user.to_hash.each{ |k,v| puts "#{v.class.name} :#{k}##{v}" } if status.user.following?
    #puts status.user.methods - Object.methods
  end
end

client.userstream

