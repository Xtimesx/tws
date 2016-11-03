raise unless !!DB
require 'twitter'
Twitter::Tweet.class_eval do
  def save
    user.save
    data = {}
    fields.each do |field|
      data[field] = self.to_hash[field]
    end
    data[:user_id] = user.id
    data[:retweeted] = false
    if retweeted_status.class.name != 'Twitter::NullObject'
      retweeted_status.save
      data[:retweeted] = true
    end
    quoted_status.save if quote?
    if dataset.where(id: id).count > 0
      dataset.where(id: id).update data
    else
      dataset.where(id: id).insert data
    end
    save_taggings
    raise "hav not saved" unless dataset.where(id: id).first
  end

  def load_context(depth: 2)
    context = [self]
    last_tweet = self
    depth.times do
      if last_tweet.in_reply_to_status_id.class.name != 'Twitter::NullObject'
        prev_tweet= dataset.where(id: last_tweet.in_reply_to_status_id).first
        if prev_tweet
          break unless prev_tweet
          prev_tweet[:user] = DB.from(:user).where(id: prev_tweet[:user_id]).order_by(Sequel.desc(:db_id)).limit(1).last
          prev_tweet = Twitter::Tweet.new(prev_tweet)
          last_tweet = prev_tweet if prev_tweet
          context << prev_tweet if prev_tweet
        end
      else
        context << user
        break
      end
    end
    context.compact.reverse
  end

  private

  def fields
      fiels = [:id, :text, :created_at, :source,
       :truncated, :in_reply_to_status_id, :in_reply_to_user_id,
        :in_reply_to_screen_name, :is_quote_status,
        :retweet_count, :favorite_count, :favorited,
        :possibly_sensitive,:filter_level, :lang, :timestamp_ms]
  end

  def dataset
    dataset = DB.from(:status)
  end

  def save_taggings
    hashtags.each do |tag|
      tag.save
      DB["INSER OR IGNORE INTO taggings (tag_name, status_id) VALUES(?,?)", tag.text ,id ]
    end
  end

end

Twitter::Entity::Hashtag.class_eval do
  def save
    #puts dataset.where(name: text).count
    unless dataset.where(name: text).count > 0
      dataset.insert(name: text)
    end
    puts "error while saving ##{text}" unless dataset.where(name: text).count == 1
  end

  def dataset
     dataset = DB.from(:tags)
  end
end

Twitter::User.class_eval do
  def save
    data = {}
    fields.each do |field|
      data[field] = self.to_hash[field]
    end
    dataset.insert data
  end
  private
  def dataset
    dataset = DB.from(:user)
  end

def fields

   [:id, :name, :screen_name, :location,
   :url , :description, :protected,
   :verified, :followers_count, :friends_count,
   :listed_count, :favourites_count, :statuses_count,
   :created_at,:geo_enabled, :lang, :contributors_enabled,
   :is_translator, :profile_background_color,
   :profile_background_image_url, :profile_background_image_url_https,
   :profile_background_tile, :profile_link_color,
   :profile_sidebar_border_color, :profile_sidebar_fill_color,
   :profile_text_color, :profile_use_background_image,
   :profile_image_url, :profile_image_url_https,
   :profile_banner_url,:default_profile,:default_profile_image,
   :following]

  end
end

module Media_save
  def save
    data = {}
    fields.each do |field|
      data[field] = self.to_hash[field]
    end
    data[:local_path] = file_path
    dataset.insert data
  end

  def download(options= {})
    options = {
      folder: '.'
    }.merge(options)
    command = "curl -XGET '#{media_uri}' -o #{file_path(options)} --create-dirs -s"
    #puts command if @debug
    system command
  end


  def file_path(options = {})
    options = {
      folder: '.'
    }.merge(options)
    path = ['.','image']
    path << options[:folder]
    path = path.join('/')
    filename = file_name
    @file_path ||= "#{path}/#{filename}"
  end

  def file_name

  base_uri = case self
  when Twitter::Media::Video
    video_info.variants.select{|v| v[:content_type] == 'video/mp4'}.sort{|b,a| a[:bitrate] <=> b[:bitrate]}.first[:url]
  else
    media_uri
  end
    @filename ||= base_uri.to_s.split('/').last
  end

  private

  def dataset
    dataset = DB.from(:media)
  end

  def fields
   [:id, :media_url,:media_url_https, :url, :display_url,
   :expanded_url, :type, :source_status_id, :source_user_id]
  end

end

Twitter::Media::Photo.class_eval do
include Media_save
end

Twitter::Media::Video.class_eval do
include Media_save
end
