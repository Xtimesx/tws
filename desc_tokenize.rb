t = Time.now
require './mnt'
require './parser'
p = Parser.new
descriptions = {}
per = 100
puts 'init done after:', Time.now - t
t = Time.now
10.times do |i|
 descriptions = DB.from(:user).select(:description, :screen_name).group_by(:id).order_by(:db_id).limit(per,i*per).where("description IS NOT NULL").map.inject(descriptions){|des,d|
 des[d[:screen_name]] = "#{d[:description]} \r\n #{ des[d[:screen_name]]}"
 des
 }
end
puts 'done fetching after:', Time.now - t
t = Time.now
#tokens = descriptions.select{|k,d| d }.map{ |k,d| t=d.split(/[♥️✪|•☾✚∆✗]|[.!?] | \/\/ | [-\/] |\r\n|\n/).map(&:strip); puts t.inspect ;[k,t] }
#tokens = descriptions.select{|k,d| d }.map{ |k,d| t=d.split(/[♥️✪|•☾✚∆✗]|[.!?] | \/\/ | [-\/,] |\r\n|\n/).map(&:strip); puts t.inspect ;[k,t] }
#tokens = descriptions.select{|k,d| d }.map{ |k,d| t=d.split(/[♥️✪|•☾✚∆✗]|[.!?] | [\/ ]{2} | [-\/,] |\r\n|\n/).map(&:strip); puts t.inspect ;[k,t] }
tokens = descriptions.select{|k,d| d }.map.inject({}){ |r,kd|
  r[kd[0]] =p.parse_tokens(kd[1])
  r
}

#tokens = tokens.to_h
mts = p.tokens_to_mappings(tokens)
puts 'done breaking down data after:', Time.now - t, "with #{mts.length} users"
# puts 'mts.inspect', mts.inspect
#tokens.each{ |k,v| 
#  puts k.rjust(30,'~'), v.map{ |m,n| 
#    "#{m.ljust(40)} #{n}"
#  } 
#}

#mts.each{ |k,v| puts k, v.map{|m,n| "#{m}: \t #{n}"} };nil
#mts.each{ |k,v| puts k.rjust(30,'~'), v.map{|m,n| "#{m.ljust(40)} #{n}"} };nil
mts.keys.each do |z| 
  puts z.rjust(30,'~')
  puts 'desc'.rjust(20,'~')
  puts descriptions[z]
 # puts URI.extract descriptions[z] if descriptions[z]
 # puts 'tokens:'.rjust(20,'~')
 # puts tokens[z]
  puts 'K V:'.rjust(20,'~')
  if mts[z]
    puts mts[z].map{ |m,n| 
      "#{m.inspect.ljust(40)} #{n}"
    }
  end
end


