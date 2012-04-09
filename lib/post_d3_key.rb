
USER_AGENT = "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.83 Safari/535.11"

# post a d3 beta key to a battle.net account
#
#  @param account_name - the URL ENCODED account name to post the key to
#  @param password - the URL ENCODED password to post the key to
#  @param d3_key - key to post and claim
#
#  @return nil
def post_d3_key account_name, password, d3_key
  log_file = "log/" + d3_key + "-" + Time.now.utc.to_s.gsub(/\s/, "-")
  `mkdir -p log`
  `mkdir -p tmp`
  `rm tmp/*`
  
  `curl --user-agent "#{USER_AGENT}" -v -L --cookie-jar tmp/cookie -d "accountName=#{account_name}&password=#{password}&persistLogin=on" https://us.battle.net/login/en/ 2>&1 >> #{log_file}`
  `curl --user-agent "#{USER_AGENT}" -v --cookie tmp/cookie --cookie-jar tmp/cookie2 -d "gameKey=#{d3_key}" https://us.battle.net/account/management/add-game.html  2>&1 >> #{log_file}`
  nil
end
