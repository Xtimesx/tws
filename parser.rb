
class Parser
require 'emoji'
require 'uri'

def parse_tokens(string)
  # split after urls
  string.instance_eval do
    # hacky AF
    def html_safe?
      true
    end
  end 
  string = Emoji.replace_unicode_moji_with_name(string)
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
  result
end

def tokens_to_mappings(tokens)
# implement lists in language, list:
# one, two and three
mts = tokens.map{ |k,t|
  [k,string_to_mappings(t)]
}.to_h
#mts = mts.select{ |k,v| v && v.any? }
puts mts.inspect
#mts=mts.map{|k,v|
# [k, v]
#}.to_h
mts
end
end
