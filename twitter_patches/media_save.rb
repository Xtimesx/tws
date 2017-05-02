module Tws
  module TwitterPatches
    module MediaSave
      include Tws::TwitterPatches::Base
      def save
        data = collect_data
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

      def base_uri
        case self
        when Twitter::Media::Video
          video_info.variants.select{|v| v.content_type == 'video/mp4'}.sort{|b,a| a.bitrate <=> b.bitrate}.first[:url]
        else
          media_uri
        end
      end

      def file_name
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
  end
end
