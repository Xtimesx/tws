require "http/server"
require "json"

class TwitterImageRequest
  JSON.mapping({
    job_iD: {type: Int64, nilable: true},
    uniq_name: String,
    src: String,  
  }, true)
end

class TwitterImageResponse
  JSON.mapping({
    job_iD: Int64,
    uniq_name: String,
    src: String,
    status: String,  
  })
end
# config #
ENV["server_address"] ||= "127.0.0.1"
ENV["server_port"] ||= "8080"
ENV["folder_prefix"] ||= "./assets/image/"
uniq_name_reqex = /^[0-9]+\/[0-9a-zA-Z\-_]+\.(jpg|png)$/

puts "server starting at #{ENV["server_address"]}:#{ENV["server_port"]}"

server = HTTP::Server.new(ENV["server_address"], ENV["server_port"].to_i, [HTTP::StaticFileHandler.new(ENV["folder_prefix"], true)]) do |context|
  res, cde = "", 200
  begin
    puts context.request.inspect
    case context.request.method
    when "POST" then
      res += context.request.inspect
      if !(b=context.request.body).nil? 
        res += "body: #{b.inspect}"
        if !b.empty?
          job_request = TwitterImageRequest.from_json(b) 
          res += job_request.inspect

          raise "uniq_name invalid" unless job_request.uniq_name =~ uniq_name_reqex
          raise "src is not twitter image server" unless job_request.src =~ /^https?:\/\/pbs\.twimg\.com\/(media|tweet_video_thumb)\/[0-9a-zA-Z\-_]+\.(jpg|png)$/

          command = "curl -XGET '#{job_request.src}' -o #{ENV["folder_prefix"]}#{job_request.uniq_name} --create-dirs -s"

    	  raise "Job Failed" unless system(command)
        end
      end
      context.request.query_params.each do |k,v| 
        context.response.print "#{k}: #{v}\n" 
      end
    when "GET" then
      res= "invalid Path" unless context.request.path =~ /\/[a-z0-9]+\.(jpg|png)/
    else
      raise "invalid request Method"
    end
  rescue e
    puts e
    cde=500
    res= HTTP.default_status_message_for(cde)
  end
  context.response.content_type = "text/plain"
  context.response.status_code = cde
  context.response.print res
end

server.listen