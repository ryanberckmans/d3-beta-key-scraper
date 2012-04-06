require 'twitter/json_stream'
require 'json'

# synchronously consume a twitter stream, returning when yield returns true
#  @param twitter_login - credentials to access stream "USER:PASS"
#  @param track - topics to filter stream for e.g. "soccer,BlizzardCS"
#  @yields text - text of each received tweet
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

    stream.each_item do |item|
      text = JSON.parse(item)["text"]
      puts item
      EventMachine::stop_event_loop if yield text        
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
      $stderr.print "retry #{retries}\n"
      $stderr.flush
    end

    stream.on_max_reconnects do |timeout, retries|
      # Something is wrong on your side. Send yourself an email.
      $stderr.print "max retries\n"
      $stderr.flush
    end
  end
  nil
end
