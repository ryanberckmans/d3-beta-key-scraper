require 'twitter/json_stream'
require 'json'


# private. if json_item is a tweet, yield the screen_name/tweet_text/created_at and stop the event loop if block returns true
#
#  @param event_machine - reference to EventMachine module, injectable for testing
#  @param json_item - parse json_item and look for "screen_name", "text", and "created_at" attribs
#  @yields screen_name,tweet_text,created_at if json_item is a tweet

#  Stop EM loop if block returns true.
#
#  @return nil
def yield_if_tweet event_machine, json_item, &block
  raise "expecting a block" unless block_given?
  parsed_item = JSON.parse json_item rescue nil
  puts parsed_item
  screen_name = parsed_item['user']['screen_name'] rescue nil
  tweet_text = parsed_item['text'] rescue nil
  created_at = parsed_item['created_at'] rescue nil
  yield screen_name, tweet_text, created_at if screen_name and tweet_text and created_at
  nil
end

# synchronously consume a twitter stream and pass each received json_item to yield_if_tweet
#
#  must be called inside EventMachine::run
#
#  @param twitter_login - credentials to access stream "USER:PASS"
#  @param content - querystring to pass to twitter's filter.json
#  @param block - block passed to yield_if_tweet with each json
#
#  @return nil 
def twitter_stream twitter_login, content, &block
  raise "expecting a block" unless block_given?

  stream = Twitter::JSONStream.connect(
                                       :path    => "/1/statuses/filter.json?#{content}",
                                       :auth    => twitter_login,
                                       :ssl     => true,
                                       )

  stream.each_item do |json_item|
    yield_if_tweet EventMachine, json_item, &block
  end

  stream.on_error do |message|
    # No need to worry here. It might be an issue with Twitter. 
    # Log message for future reference. JSONStream will try to reconnect after a timeout.
    $stderr.print message + "\n"
    $stderr.flush
  end

  stream.on_reconnect do |timeout, retries|
    # No need to worry here. It might be an issue with Twitter. 
    # Log message for future reference. JSONStream will try to reconnect after a timeout.
    $stderr.print "reconnect retry #{retries}\n"
    $stderr.flush
  end

  stream.on_max_reconnects do |timeout, retries|
    # Something is wrong on your side. Send yourself an email.
    $stderr.print "reconnect max retries\n"
    $stderr.flush
  end
  nil
end
