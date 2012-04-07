require "get_d3_key_from_twitter"

describe "get_d3_key_from_twitter" do
  it "calls twitter_stream, forwards results to parse_d3_key, and returns successful key" do
    twitter_login = "foo:bar"
    stream_filter = "some_filter,romg,1334"
    blizzard_screen_name = "jim"
    tweet_text = "abc def sdfkljkl"
    key = "the key\n2308023498  \t #*#  "
    key_stripped = "thekey2308023498"

    D3KeyFromTwitter.any_instance.should_receive(:twitter_stream).with(twitter_login, stream_filter).once.and_yield(blizzard_screen_name,tweet_text).and_yield(blizzard_screen_name,tweet_text).and_yield(blizzard_screen_name,tweet_text).and_return(nil)

    D3KeyFromTwitter.any_instance.should_receive(:parse_d3_key).with(blizzard_screen_name, blizzard_screen_name, tweet_text).exactly(3).times.and_return(nil,nil,key)
    
    result_key = D3KeyFromTwitter.new.get_d3_key_from_twitter twitter_login, stream_filter, blizzard_screen_name

    result_key.should eq(key_stripped)
  end
end
