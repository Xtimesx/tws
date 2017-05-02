module Tws
  module TwitterPatches
    module Status
      require './twitter_patches/base'
      include Tws::TwitterPatches::Base
      def save
        user.save
        data = collect_data
        data[:user_id] = user.id
        data[:retweeted] = false
        if retweeted_status.present?
          retweeted_status.save
          data[:retweeted] = true
        end
        quoted_status.save if quote?
        begin
          dataset.insert_conflict(:replace).insert data
          save_taggings
        rescue Sequel::UniqueConstraintViolation
          #already saved
        end
        raise "hav not saved" unless dataset.where(id: id).first
      end

      def load_context(depth: 2)
        context = [self]
        last_tweet = self
        depth.times do
          unless last_tweet.in_reply_to_status_id.nil?
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
          DB[:taggings].insert_ignore.insert tag_name: tag.text, status_id: id
        end
      end
    end
  end
end
