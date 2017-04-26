require './mnt'

DB.create_table :media do
 primary_key :db_id
 BigInt :id #711120424453672961
 String :media_url #http://pbs.twimg.com/media/Cd5oQiQWEAE2Syk.jpg
 String :media_url_https #https://pbs.twimg.com/media/Cd5oQiQWEAE2Syk.jpg
 String :url #https://t.co/4GmB5yaEI9
 String :display_url #pic.twitter.com/4GmB5yaEI9
 String :expanded_url #http://twitter.com/CutieTingz/status/711120424600530944/photo/1
 String :type #photo
 #Hash :sizes #{:medium=>{:w=>337, :h=>450, :resize=>"fit"}, :thumb=>{:w=>150, :h=>150, :resize=>"crop"}, :small=>{:w=>337, :h=>450, :resize=>"fit"}, :large=>{:w=>337, :h=>450, :resize=>"fit"}}
 BigInt :source_status_id #711120424600530944
 BigInt :source_user_id #2309326454

end

DB.create_table :status do
  primary_key :db_id
  BigInt :id, unique: true, null: false
  String :text,  :null => false
  #foreign_key :category_id, :categories
  DateTime :created_at
  #BigDecimal :user_id, null: false

  String :source
  FalseClass :truncated
  BigInt :in_reply_to_status_id
  BigInt :in_reply_to_user_id
  String :in_reply_to_screen_name
  BigInt :user_id
  #NilClass :contributors
  #Hash :retweeted_status
  FalseClass :is_quote_status
  Fixnum :retweet_count
  Fixnum :favorite_count
  #Hash :entities
  #Hash :extended_entities
  FalseClass :favorited
  FalseClass :retweeted
  FalseClass :possibly_sensitive
  String :filter_level
  String :lang
  String :timestamp_ms

  index :id
  index :created_at
end

DB.create_table :user do
 primary_key :db_id
 BigInt :id, null: false
 String :name
 String :screen_name
 String :location
 String :url , null: true
 String :description, text: true
 FalseClass :protected
 FalseClass :verified
 Fixnum :followers_count
 Fixnum :friends_count
 Fixnum :listed_count
 Fixnum :favourites_count
 Fixnum :statuses_count
 String :created_at
 TrueClass :geo_enabled
 String :lang
 FalseClass :contributors_enabled
 FalseClass :is_translator
 String :profile_background_color
 String :profile_background_image_url
 String :profile_background_image_url_https
 FalseClass :profile_background_tile
 String :profile_link_color
 String :profile_sidebar_border_color
 String :profile_sidebar_fill_color
 String :profile_text_color
 FalseClass :profile_use_background_image
 String :profile_image_url
 String :profile_image_url_https
 String :profile_banner_url
 FalseClass :default_profile
 FalseClass :default_profile_image
 String :following

end
