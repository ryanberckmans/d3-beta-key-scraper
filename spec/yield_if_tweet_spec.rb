require "cartesian"
require "json"
require "twitter_stream"

######################################
# test data to generate tests

VALID_TWEET_JSONS = [
                     '{ "text": "this is the tweet text", "user": { "screen_name": "bob" } }', # valid
             ]

INVALID_TWEET_JSONS = [
                       nil,
                       '{}',
                       '{ "user": { "screen_name": "bob" }}', # invalid - no text
                       '{ "text": "this is the tweet text" }', # invalid - no user
                       '{ "text": "this is the tweet text", "user": {} }', # invalid - no screen name
                      ]

TWEET_JSONS = INVALID_TWEET_JSONS + VALID_TWEET_JSONS

TWEET_JSONS.each { |tweet_json| JSON.parse tweet_json unless tweet_json.nil? } # sanity, make sure TWEET_JSONS are parsable

BLOCK_RETURN_VALUES = [
                       false,
                       true,
                      ]

######################################
# functions to generate tests

# setup mock expectations for given test data
def yield_if_tweet_expected_result event_machine, tweet_json, block, block_return_value
  if VALID_TWEET_JSONS.include? tweet_json
    block.should_receive(:call).with(instance_of(String), instance_of(String)).once
    if block_return_value
      event_machine.should_receive(:stop_event_loop).with(no_args).once
    else
      event_machine.should_not_receive :stop_event_loop
    end
  else
    block.should_not_receive :call
    event_machine.should_not_receive :stop_event_loop
  end
end

# generates one test for each tuple in the cartesian product of test data
def generate_tests
  for tweet_json, block_return_value in TWEET_JSONS.x BLOCK_RETURN_VALUES
    test_description = "tweet_json: '#{tweet_json}', block_return_value: '#{block_return_value.to_s}'"
    #puts "scheduling test #{test_description}"
    generate_one_test test_description, tweet_json, block_return_value
  end
end

def generate_one_test test_description, tweet_json, block_return_value
  it test_description do
    event_machine = double "event_machine"
    block = double "block"
    yield_if_tweet_expected_result event_machine, tweet_json, block, block_return_value
    yield_if_tweet( event_machine, tweet_json ) { |screen_name,tweet_text| block.call screen_name, tweet_text; block_return_value }
  end
end

######################################
# execute test model

describe "yield_if_tweet" do
  generate_tests
end
