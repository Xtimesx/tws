module Tws
  module StatusDownloader
    def self.download(status)
      threads = []
      status.media.each do |m|
        threads << Thread.new(status) do |status|
          uniq_name= "#{status_id(status)}/#{m.file_name}"
          uri = URI("http://127.0.0.1:8080")
          begin
            Net::HTTP.start(uri.host, uri.port) do |http|
              request = Net::HTTP::Post.new uri
              request.body = request_body uniq_name, m.base_uri
              response = http.request request # Net::HTTPResponse object
              Thread.current[:code] = response.code
            end
          rescue Net::ReadTimeout
            # Well, fuck
          end
          Thread.current[:uri] = uri.to_s + '/' + uniq_name
          Thread.current[:path] = "file://#{File.expand_path("./assets/" + m.file_path(folder: status_id(status).to_s))}"
        end
      end

      result = []

      threads.each do |t|
        t.join
        result << "#{t[:code]} for: #{t[:path]}"
      end
      result
    end

    def self.request_body uniq_name, media_uri
       "{ \"job_iD\": #{rand(2**30)}, \"uniq_name\": \"#{uniq_name}\", \"src\": \"#{media_uri}\" }"
    end

    def self.status_id status
      (status.retweeted_status? ? status.retweeted_status.id : status.id).to_s(16).upcase.scan(/../).join('/')
    end
  end
end
