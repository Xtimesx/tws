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

folder_prefix = "tmp/cr/"

server = HTTP::Server.new("0.0.0.0", 8080,[HTTP::StaticFileHandler.new("./tmp/cr/", false)]) do |context|
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
          command = "curl -XGET '#{job_request.src}' -o #{folder_prefix}#{job_request.uniq_name} --create-dirs -s"
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