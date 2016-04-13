def say(text,options = {})
  options = { lang: 'en', voice: 'female2' }.merge(options)
  raise unless AVADIBLE_VOICES.include?(options[:voice])
  text = text.gsub(/https?[^[ ]]*/, " ").gsub(/['#]/,"")
  instruction =("spd-say '#{text}' -l '#{options[:lang]}' --voice-type #{options[:voice]} ")
  #puts instruction
  system instruction
end

def voiceForUserByName(name)
  result = NAME_VOICE_MAPPING[name]
  result || AVADIBLE_VOICES[(name[0].bytes.to_a.first || 0) % AVADIBLE_VOICES.length]
end