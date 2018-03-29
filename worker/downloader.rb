#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"
require './mnt'
require './twitter_patches'
require './downloader'

conn = Bunny.new(:automatically_recover => false)
conn.start

ch_in  = conn.create_channel
x = ch_in.topic("tweets")
q = ch_in.queue("", :exclusive => true)

q.bind(x, routing_key: '#.img')

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
  q.subscribe(:block => true) do |delivery_info, properties, body|
    array = JSON.parse body
    status = Twitter::Tweet.new(symbolize_keys(array.first))

    puts Tws::StatusDownloader.download status
  end
rescue Interrupt => _
  conn.close
 puts "eeeeeee"
  exit(0)
end
