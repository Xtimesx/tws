#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"
require 'tweetstream'
require './config' # clean up DB

conn = Bunny.new(:automatically_recover => false)
conn.start

ch   = conn.create_channel
q    = ch.queue("raw_statuss", :durable => true)

client = TweetStream::Client.new

client.on_error do |message|
  puts message
end

client.on_direct_message do |direct_message|
  puts
  puts direct_message.full_text
end

client.on_timeline_status do |status|
  hash = status.to_h
  hash.merge! hash.fetch(:extended_tweet, {})
  hash[:text] = hash.fetch(:extended_tweet, {}).fetch(:full_text, hash[:text])
  hash[:text] = hash.fetch(:extended_tweet, {}).fetch(:full, hash[:text])
  q.publish(hash.to_json, persistent: true)
end

begin

    client.userstream(tweet_mode: 'extended')
rescue Interrupt => _
  conn.close
 puts "eeeeeee"
  exit(0)
end
