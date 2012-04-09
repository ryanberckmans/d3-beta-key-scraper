
USER_AGENT = "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.83 Safari/535.11"

# login to a battle.net account, storing cookies for later use
#
#  @param account_name - the URL ENCODED account name to login to
#  @param password - the URL ENCODED password to logint o
#
#  @return nil
def login_to_battlenet account_name, password
  log_file = "log/login-" + Time.now.utc.to_s.gsub(/\s/, "-")
  `mkdir -p log`
  `mkdir -p tmp`
  `rm tmp/*`

  `curl --user-agent "#{USER_AGENT}" -v -L --cookie-jar tmp/cookie -d "accountName=#{account_name}&password=#{password}&persistLogin=on" https://us.battle.net/login/en/ 2>&1 >> #{log_file}`
  puts "logged in to battlenet, log: #{log_file}"
  nil
end

# post a d3 beta key using cached battle.net credentials
#
#  @param d3_key - key to post and activate
#
#  @return nil
def post_d3_key d3_key
  log_file = "log/" + d3_key + "-" + Time.now.utc.to_s.gsub(/\s/, "-")
  `mkdir -p log`
  `mkdir -p tmp`
  
  `curl --user-agent "#{USER_AGENT}" -v --cookie tmp/cookie --cookie-jar tmp/cookie2 -d "gameKey=#{d3_key}" https://us.battle.net/account/management/add-game.html  2>&1 >> #{log_file}`
  puts "posted d3 key: #{d3_key}, posted_at: #{Time.now.to_s}"
  nil
end
