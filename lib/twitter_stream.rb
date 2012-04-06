require 'twitter/json_stream'
require 'json'

# synchronously consume a twitter stream, returning when yield returns true
#  @param twitter_login - credentials to access stream "USER:PASS"
#  @param track - topics to filter stream for e.g. "soccer,BlizzardCS"
#  @yields screen_name, text - screen_name (i.e. from field) and text of each received tweet
#
#  @return nil 
def twitter_stream(twitter_login, track)
  raise "expecting a block" unless block_given?
  
  EventMachine::run do
    stream = Twitter::JSONStream.connect(
                                         :path    => "/1/statuses/filter.json?track=#{track}",
                                         :auth    => twitter_login,
                                         :ssl     => true,
                                         )

    stream.each_item do |json_item|
      parsed_item = JSON.parse json_item rescue nil
      screen_name = parsed_item['user']['screen_name'] rescue nil
      text = parsed_item["text"] rescue nil
      EventMachine::stop_event_loop if screen_name and text and yield screen_name, text
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
  end
  nil
end
