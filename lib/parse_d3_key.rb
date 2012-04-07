
# return successfully obtained d3_key else nil
#  @param blizzard_screen_name - screen name tweet must be from to contain key
#  @param tweet_screen_name - tweeter's screen name
#  @param tweet_text - candidate text containing key
#
#  @return key or nil
def get_d3_key blizzard_screen_name, tweet_screen_name, tweet_text
  return nil unless blizzard_screen_name and tweet_screen_name and blizzard_screen_name == tweet_screen_name
  parse_d3_key tweet_text
end


# diablo 3 beta key format: 6-4-6-4-6 alphanumeric characters (length 26)
KEY_PATTERN = /(?<key>[a-zA-Z0-9]{6}-*[a-zA-Z0-9]{4}-*[a-zA-Z0-9]{6}-*[a-zA-Z0-9]{4}-*[a-zA-Z0-9]{6})/
# TODO allow whitespace or dashes between char groups


# private. return nil on parse failure xor d3_key
def parse_d3_key text
  match = KEY_PATTERN.match text rescue nil
  match[:key] if match
end
