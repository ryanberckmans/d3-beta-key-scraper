require "twitter_stream"
require "parse_d3_key"
require "post_d3_key"

class D3KeyFromTwitter
  BATTLENET_LOGIN_INTERVAL = 60*15 # seconds

  # monitor a twitter account, posting all diablo 3 keys to the passed battle.net account
  #
  #  @param twitter_login - credentials to access twitter stream "USER:PASS"
  #  @param stream_filter - querystring to append to twitter's filter.json?
  #  @param blizzard_screen_name - tweeter of diablo 3 beta key
  #  @param battlenet_user - battle.net account to post key to
  #  @param battlenet_password - password of battle.net account to post key to
  #
  #  @return nil
  def activate_d3_key_from_twitter twitter_login, stream_filter, blizzard_screen_name, battlenet_user, battlenet_password
    periodic_battlenet_login battlenet_user, battlenet_password
    twitter_stream twitter_login, stream_filter do |screen_name, tweet_text, created_at|
      puts "#{screen_name}: #{tweet_text}\n"
      d3_key = parse_d3_key blizzard_screen_name, screen_name, tweet_text
      next unless d3_key
      puts "found d3 key: #{d3_key}, created_at (server time): #{created_at}, scraped_at: #{Time.now.to_s}"
      d3_key_stripped = d3_key.gsub /[^a-zA-Z0-9]/, ''
      post_d3_key d3_key_stripped
    end
    nil
  end

  private
  def periodic_battlenet_login battlenet_user, battlenet_password
    login_to_battlenet battlenet_user, battlenet_password # login immediately so we're logged in during first timer interval
    EventMachine::add_periodic_timer( BATTLENET_LOGIN_INTERVAL ) { login_to_battlenet battlenet_user, battlenet_password }
  end
end
