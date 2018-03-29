DB = {} #dummy
require "bunny"
require 'json'
require 'twitter'
require './twitter_patches'

conn = Bunny.new(:automatically_recover => false)
conn.start

ch_in  = conn.create_channel
x = ch_in.topic("tweets")
q = ch_in.queue("", :exclusive => true)

q.bind(x, routing_key: '#')

def symbolize_keys(hash)
  return hash unless hash.is_a? Hash
  keys = hash.keys

  n = {}

  keys.each do |k|
    n[k.to_sym] = case hash[k]
    when Hash
      symbolize_keys(hash[k])
    when Array
      hash[k].map{ |d| symbolize_keys(d) }
    else
      hash[k]
    end
  end
  return n
end
def show(status)
  case status.class.name
  when 'Twitter::Tweet'
    puts status.full_text.gsub('&gt;','>').gsub('&lt;','<').gsub('&amp;','&') 
  when 'Twitter::User'
    puts "#{status.screen_name}/#{status.name}"
    puts status.description
    puts status.location
  else
    puts status.class.name
    status.inspect
  end
end

begin
  q.subscribe(:block => true) do |delivery_info, properties, body|
    array = JSON.parse body
    context = array.map do |t|
      if t['screen_name']
        Twitter::User.new(symbolize_keys(t))
      else
       h = symbolize_keys(t)
       h.merge! h[:extended_tweet] if h[:extended_tweet] 
       Twitter::Tweet.new(h)
      end
    end
    context.each do |tweet|
      show(tweet)
      puts '~~~~~~~~~~~~~~~~~'
    end
  end
rescue Interrupt => _
  conn.close
 puts "eeeeeee"
  exit(0)
end
