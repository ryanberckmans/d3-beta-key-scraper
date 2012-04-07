require "twitter_stream"
require "parse_d3_key"

# monitor the twitter stream until a diablo 3 key is found
#
#  @param twitter_login - credentials to access twitter stream "USER:PASS"
#  @param stream_filter - querystring to append to twitter's filter.json?
#  @param blizzard_screen_name
def get_d3_key_from_twitter twitter_login, stream_filter, blizzard_screen_name
  d3_key = nil
  twitter_stream twitter_login, stream_filter do |screen_name, tweet_text|
    puts "#{screen_name}: #{tweet_text}\n"
    d3_key = get_d3_key blizzard_screen_name, screen_name, tweet_text
    if d3_key
      puts "found d3 key: #{d3_key}"
      true # true ends twitter stream
    else
      false # false continues twitter stream
    end
  end
  d3_key
end
