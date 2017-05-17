require './mnt'
require './user_time_scanner'

def tag_search(tagname)
  puts "tag: ##{tagname}"
  DB.from(:status).
  join(:taggings, :status_id => :id).
  join(:tags, taggings__tag_name: :tags__name).
  left_join(:media, :source_status_id => :status__id).
  where(Sequel.like(:tags__name, tagname)).
  order_by(Sequel.desc(:status__db_id)).limit(50)
end

def user_search(username)
  puts "user: @#{username}"
  user = DB.from(:user).
  where(Sequel.like(:user__screen_name, "%#{username}%")).
  group_by(:id).first
  id = user[:id]
  tweet_times_table_for(user[:screen_name])

  DB.from(:status).
  left_join(:media, :source_status_id => :status__id).
  where(status__user_id: id).
  order_by(Sequel.desc(:status__db_id)).limit(10)
end

def text_search(text)
  puts "text: \"#{text}\""
  DB.select{status__id.distinct}.from(:status).
  left_join(:media, :source_status_id => :status__id).
  where(Sequel.like(:status__text, "%#{text}%")).
  order_by(Sequel.desc(:status__db_id)).limit(50)
end

def asset_search(text)
  puts "text: \"#{text}\""
  DB.from(:status).
  join(:media, :source_status_id => :status__id).
  where(Sequel.like(:status__text, "%#{text}%")).
  group_by(:status__id).
  order_by(Sequel.desc(:status__db_id)).limit(50)
end

puts 'tag to search in database'
search = gets.chomp 
dataset = case search[0]
  when '#'
    tag_search(search[1,search.length])
  when '@'
    user_search(search[1,search.length])
  when '?'
    asset_search(search[1,search.length])
  else
    text_search(search)
end
puts dataset.sql
dataset.each do |r|
  #puts r.inspect
  #puts r[:local_path].inspect
  file = !!r[:local_path] ? "file://#{File.expand_path("./assets/" +  r[:local_path])}" : ""
  puts "#{r[:text]}: #{file}"
  puts "#{r[:name]}/#{r[:screen_name]}"
end
