
class Parser
require 'twemoji'
require 'uri'
Emoji = Twemoji

def split_at_sentences_end(string)
  sentence_regexp = /[^[A-Z\W]]{2}\.\s/
  if string =~ sentence_regexp
    result = []
    while i = string.index(sentence_regexp)
      result << string[0..i+2]
      string = string[i+3..-1]
    end
    result << string
    result
  else
    string
  end
end

def split_after_uri(string)
  result = []
  uris= URI.extract(string).select do |u|
    ur=URI.regexp.match(u)
    ur = ur[1]
    URI.scheme_list.keys.include? ur.upcase
  end
  while uris.length > 0 && string
    uri = uris.shift
    ind = string.index(uri)
    result << string[0..(ind+uri.length)] if ind
    string = string[ind+uri.length+1..-1] if ind
  end
  result << string
  result
end

def parse_tokens(string)
  # split after urls
  string.instance_eval do
    # hacky AF
    def html_safe?
      true
    end
  end 
  string = string.gsub(Emoji.emoji_pattern_unicode) do |hit|
    Emoji.find_by_unicode(hit).gsub(':','´') || hit
  end
  regexp = /[🔥🌿🏓;♥️✪♡／|•☾✚★∆✗\{\}]|[!? ] | [\/ :]{2,} | [~*·\-\/,] |\r\n|\n/
  string.split(regexp).
  map(&:strip).map{ |s|
    split_at_sentences_end(s)
  }.flatten.
  map{ |s|
    split_after_uri(s)
  }.flatten.
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
      string[(i+2)..-1].split(split_regexp).map(&:strip).flatten.map{ |p| 
        word_split p
      }
    }
   else
     word_split string
     #{ string => nil}
   end

end

def colons_split(string)
  result = {}
  n= string.map{ |e|
    result = result.merge colon_split(e)
  }
  result
end

def decomposite(obj)

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
end
end
