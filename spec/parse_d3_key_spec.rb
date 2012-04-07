require "cartesian"
require "parse_d3_key"



######################################
# test data to generate tests

KEY_PLACEHOLDER = "KEY_PLACEHOLDER"

BLIZZARD_SCREEN_NAMES = [
                         nil,
                         "fred",
                         "multi token with CAPS and crazy stuff!!",
                         "12338",
                        ]
TEXT_SCREEN_NAMES = BLIZZARD_SCREEN_NAMES
TEXTS = [
         nil,
         "#{KEY_PLACEHOLDER}",
         "the key is: #{KEY_PLACEHOLDER}",
         "We're pleased to announce the winning key: \"#{KEY_PLACEHOLDER}\"!!!   omg",
         "-#{KEY_PLACEHOLDER}---", "  #{KEY_PLACEHOLDER} -",
        ]
VALID_KEYS = [
              "79zdfJ-1234-abcXXX-XXXX-XXXXXX",
              "79zdfJ1234-abcXXX--XXXX---XXXXXX",
              "1234567890abcdeedcba123GHT",
              "1234567890abcdeedcba123GHT",
              "79zdfJ-1234-abcXXX-XXXX-XXXXXX"
             ]
INVALID_KEYS = [
               ]
KEYS = VALID_KEYS + INVALID_KEYS

######################################
# functions to generate tests

# @return expected get_d3_key result for given test data
def get_d3_key_expected_result blizzard_screen_name, text_screen_name, text, key
  key if blizzard_screen_name and text_screen_name and blizzard_screen_name == text_screen_name and text and VALID_KEYS.include? key
end

# generates one test for each tuple in the cartesian product of test data
def generate_tests
  for blizzard_screen_name, text_screen_name, text, key in
    BLIZZARD_SCREEN_NAMES.x TEXT_SCREEN_NAMES.x TEXTS.x KEYS
    expected = get_d3_key_expected_result blizzard_screen_name, text_screen_name, text, key
    test_description = "tuple: blizzard_screen_name: '#{blizzard_screen_name}', text_screen_name: '#{text_screen_name}', text: '#{text}', key: '#{key}' (expected: '#{expected}')"
    #puts "scheduling test #{test_description}"
    generate_one_test test_description, blizzard_screen_name, text_screen_name, text, key, expected
  end
end

def generate_one_test test_description, blizzard_screen_name, text_screen_name, text, key, expected
  text = text.sub KEY_PLACEHOLDER, key rescue nil
  it test_description do
    get_d3_key(blizzard_screen_name, text_screen_name, text).should eq(expected)
  end
end

######################################
# execute test model

describe "parse_d3_key" do
  generate_tests
end
