require './mnt'
require 'date'
# well, this will be hard on my hardware

MIN_IN_DAY = 24 * 60
def tweet_times_table_for(screen_name, res_in_min = 30)
  raise "bad resulution" if 0 != MIN_IN_DAY % res_in_min
  user = DB.from(:user).select(:id, :screen_name).where(screen_name: screen_name).first
  user_id = user[:id]

  statuss = DB.from(:status).where(user_id: user_id).select(:created_at).all

  days=(0..6).each.inject({}) do |e, i|
    e[Date::ABBR_DAYNAMES[i]] = Array.new(MIN_IN_DAY/res_in_min,0)
    e
  end

  u = statuss.map.inject(days) do |e, o|
    u=o[:created_at];
    m=(u.hour*60+u.min)/res_in_min
    e[Date::ABBR_DAYNAMES[u.wday]][m]+= 1
    e
  end
  puts '#' * 120
  scale = (0..((MIN_IN_DAY/res_in_min)-1)).map{ |d| d *= res_in_min; "%02d%02d" % [(d-(d%60))/60,d%60] }
  0.upto(3) { |i| puts "   " + scale.map{ |k| k[i]  }.join(' ') }
  mx = u.values.max
  puts user[:screen_name]
  u.map do |day, val|
    print day, val.map{|v| case(v);when 0;' '; when 1..2;'*';when 3..4;'/';when 5..10;'%';else '#' end}.join(' '), "\n"
  end
end
