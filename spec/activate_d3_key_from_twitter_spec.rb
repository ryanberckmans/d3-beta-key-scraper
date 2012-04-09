require "activate_d3_key_from_twitter"

describe "activate_d3_key_from_twitter" do
  it "calls twitter_stream, forwards results to parse_d3_key, and posts successful key" do
    twitter_login = "foo:bar"
    stream_filter = "some_filter,romg,1334"
    blizzard_screen_name = "jim"
    battlenet_user = "fred"
    battlenet_password = "battlent#*pasS123"
    tweet_text = "abc def sdfkljkl"
    created_at = "created_at date"
    key = "the key\n2308023498  \t #*#  "
    key_stripped = "thekey2308023498"

    EventMachine.should_receive(:add_periodic_timer).with(D3KeyFromTwitter::BATTLENET_LOGIN_INTERVAL).once
    
    D3KeyFromTwitter.any_instance.should_receive(:login_to_battlenet).with(battlenet_user, battlenet_password).once

    D3KeyFromTwitter.any_instance.should_receive(:twitter_stream).with(twitter_login, stream_filter).once.and_yield(blizzard_screen_name,tweet_text,created_at).and_yield(blizzard_screen_name,tweet_text,created_at).and_yield(blizzard_screen_name,tweet_text,created_at).and_return(nil)

    D3KeyFromTwitter.any_instance.should_receive(:parse_d3_key).with(blizzard_screen_name, blizzard_screen_name, tweet_text).exactly(3).times.and_return(nil,nil,key)

    D3KeyFromTwitter.any_instance.should_receive(:post_d3_key).with(key_stripped).once.and_return(nil)
    
    result_key = D3KeyFromTwitter.new.activate_d3_key_from_twitter twitter_login, stream_filter, blizzard_screen_name, battlenet_user, battlenet_password

    result_key.should eq(nil)
  end
end
