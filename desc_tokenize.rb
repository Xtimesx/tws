require './mnt'
require 'uri'

def parse_tokens(string)
  # split after urls 
  regexp = /[🔥🌿🏓;♥️✪♡／|•☾✚★∆✗\{\}\(\)\]\[]|[.!? ] | [\/ :]{2,} | [~*·\-\/,] |\r\n|\n/
  string.split(regexp).
  map(&:strip).
  select{ |v|
    v && v.length > 0
  }

end

def word_split(string)
  # break after seperator is 'and' or '&'
  split_regexp = /[;,&]|\Wand\W/
  string_regexp = /.\w\W(on|to|by|is|of)\s/
  if string =~ string_regexp 
    i = string.index string_regexp 
    {
      string[0..(i+4)] =>
      string[(i+5)..-1].split(split_regexp).map(&:strip).map{ |s|
        s ? word_split(s) : s
      }
    }
  else
    { string => nil }
  end
end

def words_split(string)
  result = {} 
  n= string.map{ |e|
    result = result.merge word_split(e)
  }
  result
end

def colon_split(string)
  split_regexp = /[;,&]|\Wand\W/
  colon_regexp = /\w: | =/
  if string =~ colon_regexp
    i = string.index(colon_regexp)
    {
      string[0..(i)] =>
      string[(i+2)..-1].split(split_regexp).map(&:strip).flatten
    }
   else
     { string => nil}
   end

end

def colons_split(string)
  result = {}
  n= string.map{ |e|
    result = result.merge colon_split(e)
  }
  result
end

def string_to_mappings(strings)
  m = colons_split(strings) || {}
  n = words_split(strings) || {}
  result = n.merge m
  puts '#' *50
  puts 'strings', strings
  puts 'result.inspect',result.inspect
  result
end

def tokens_to_mappings(tokens)
# implement lists in language, list:
# one, two and three
mts = tokens.map{ |k,t|
  puts'k',k,'t',t 
  [k,string_to_mappings(t)]
}.to_h
#mts = mts.select{ |k,v| v && v.any? }
puts mts.inspect
#mts=mts.map{|k,v|
# [k, v]
#}.to_h
mts
end

descriptions = {}
DB.from(:user).order_by(:db_id).limit(100).where("description IS NOT NULL").map{|d| descriptions[d[:screen_name]] = "#{d[:description]} \r\n #{ descriptions[d[:screen_name]]}" }
#tokens = descriptions.select{|k,d| d }.map{ |k,d| t=d.split(/[♥️✪|•☾✚∆✗]|[.!?] | \/\/ | [-\/] |\r\n|\n/).map(&:strip); puts t.inspect ;[k,t] }
#tokens = descriptions.select{|k,d| d }.map{ |k,d| t=d.split(/[♥️✪|•☾✚∆✗]|[.!?] | \/\/ | [-\/,] |\r\n|\n/).map(&:strip); puts t.inspect ;[k,t] }
#tokens = descriptions.select{|k,d| d }.map{ |k,d| t=d.split(/[♥️✪|•☾✚∆✗]|[.!?] | [\/ ]{2} | [-\/,] |\r\n|\n/).map(&:strip); puts t.inspect ;[k,t] }
tokens = descriptions.select{|k,d| d }.map{ |k,d|
  [k,parse_tokens(d)] 
}

tokens = tokens.to_h
mts = tokens_to_mappings(tokens)

puts 'mts.inspect', mts.inspect
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


