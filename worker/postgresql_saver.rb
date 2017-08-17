#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"
require 'tweetstream'
require './mnt'
require './config' # clean up DB
require './twitter_patches'

conn = Bunny.new(:automatically_recover => false)
conn.start

ch_in  = conn.create_channel
ch_out = conn.create_channel
q_in   = ch_in.queue("raw_statuss", :durable => true)
q_out  = ch_out.topic("tweets")


ch_in.prefetch(1)
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
begin
  q_in.subscribe(:manual_ack => true, :block => true) do |delivery_info, properties, body|
puts hash = JSON.parse(body)
    tweet = Twitter::Tweet.new(symbolize_keys(hash))

    tweet.save

    tweet.media.map(&:save)

    context = tweet.load_context(depth: 10).map(&:collect_data) 
puts body
    tags = []
    tags << tweet.user.id.to_s(16)
    tags << 'pub' # add 'pri' for private
    tags << tweet.media.any? ? 'img' : 'blk'

    q_out.publish(context.to_json, routing_key: tags.join('.'))

    ch_in.ack(delivery_info.delivery_tag)
  end
rescue Interrupt => _
  conn.close
 puts "eeeeeee"
  exit(0)
end
