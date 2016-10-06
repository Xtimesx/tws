TweetStream.configure do |config|
  config.consumer_key       = 'VYF97tIjMctKTXHV9OZzLvS0D'
  config.consumer_secret    = 'oACoadguMBkJMLydsWM5rjerXJcIcENVyAkOYOKTKXYKAEjP94'
  config.oauth_token        = '3055277621-hQAjtxe6lTOlMj0s2liRbckGKHZsLLIj1a6Lxvj'
  config.oauth_token_secret = 'sKI2eJbesRaAHalT9o3YXZ0Ns1cwnovnOyg7rQlhHACEG'
  config.auth_method        = :oauth
end

NAME_VOICE_MAPPING = {
  
}

AVADIBLE_VOICES = %w(male1  male2  male3  female1 female2 female3 child_male child_female)

puts @cols = `/usr/bin/env tput cols`.to_i
@cols ||= 80

@debug = false