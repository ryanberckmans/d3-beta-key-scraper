
# diablo 3 beta key format: 6-4-6-4-6 alphanumeric characters (length 26)
KEY_PATTERN = /(^|[^a-zA-Z0-9-])(?<key>[a-zA-Z0-9]{6}[\s-]*[a-zA-Z0-9]{4}[\s-]*[a-zA-Z0-9]{6}[\s-]*[a-zA-Z0-9]{4}[\s-]*[a-zA-Z0-9]{6})($|[^a-zA-Z0-9-])/

# return successfully obtained d3_key else nil
#  @param blizzard_screen_name - blizzard's twitter screen name
#  @param tweet_screen_name - tweeter's screen name, must match blizzard to be eligible for key
#  @param tweet_text - candidate text containing key
#
#  @return key or nil
def parse_d3_key blizzard_screen_name, tweet_screen_name, tweet_text
  return nil unless blizzard_screen_name and tweet_screen_name and blizzard_screen_name == tweet_screen_name
  match = KEY_PATTERN.match tweet_text rescue nil
  match[:key] if match
end

