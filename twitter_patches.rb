raise unless !!DB
require 'twitter'
require './twitter_patches/status'
require './twitter_patches/null'
require './twitter_patches/media_save'

Twitter::NullObject.class_eval do
  include Tws::TwitterPatches::Null
end

Twitter::Tweet.class_eval do
  include Tws::TwitterPatches::Status
end

Twitter::Entity::Hashtag.class_eval do
  def save
    begin
      #puts dataset.where(name: text).count
      if DB.database_type == :postgres
        unless dataset.where(name: text).count > 0
          dataset.insert(name: text)
        end
      elsif DB.database_type == :sqlite
        dataset.insert_ignore.insert(name: text)
      end
    rescue Sequel::UniqueConstraintViolation
      puts "error while saving ##{text}" unless dataset.where(name: text).count == 1
    end
  end

  def dataset
     dataset = DB.from(:tags)
  end
end

Twitter::User.class_eval do
  include Tws::TwitterPatches::Base
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


Twitter::Media::Photo.class_eval do
include Tws::TwitterPatches::MediaSave
end

Twitter::Media::Video.class_eval do
include Tws::TwitterPatches::MediaSave
end
