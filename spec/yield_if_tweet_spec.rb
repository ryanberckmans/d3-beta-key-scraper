require "cartesian"
require "json"
require "twitter_stream"

######################################
# test data to generate tests

VALID_TWEET_JSONS = [
                     '{ "text": "this is the tweet text", "created_at": "some_date", "user": { "screen_name": "bob" } }', # valid
             ]

INVALID_TWEET_JSONS = [
                       nil,
                       '{}',
                       '{ "user": { "screen_name": "bob" }}', # invalid - no text, created_at
                       '{ "text": "this is the tweet text" }', # invalid - no user, created_at
                       '{ "text": "this is the tweet text", "user": {} }', # invalid - no screen name, created_at
                       '{ "text": "this is the tweet text", "user": { "screen_name": "bob" } }', # no created_at
                      ]

TWEET_JSONS = INVALID_TWEET_JSONS + VALID_TWEET_JSONS

TWEET_JSONS.each { |tweet_json| JSON.parse tweet_json unless tweet_json.nil? } # sanity, make sure TWEET_JSONS are parsable

######################################
# functions to generate tests

# setup mock expectations for given test data
def yield_if_tweet_expected_result event_machine, tweet_json, block
  if VALID_TWEET_JSONS.include? tweet_json
    tweet = JSON.parse tweet_json
    block.should_receive(:call).with(
                                     tweet['user']['screen_name'],
                                     tweet['text'],
                                     tweet['created_at']
                                     ).once
  else
    block.should_not_receive :call
  end
  event_machine.should_not_receive :stop_event_loop # legacy. ensure EventMachine::stop_event_loop isn't called (it used to be)
end

# generates one test for each tuple in the cartesian product of test data
def generate_tests
  for tweet_json in TWEET_JSONS
    test_description = "tweet_json: '#{tweet_json}'"
    puts "scheduling test #{test_description}"
    generate_one_test test_description, tweet_json
  end
end

def generate_one_test test_description, tweet_json
  it test_description do
    event_machine = double "event_machine"
    block = double "block"
    yield_if_tweet_expected_result event_machine, tweet_json, block
    yield_if_tweet( event_machine, tweet_json ) { |*args| block.call *args; nil }
  end
end

######################################
# execute test model

describe "yield_if_tweet" do
  generate_tests
end
