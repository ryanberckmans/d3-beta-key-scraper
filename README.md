# Diablo 3 Beta Key Scraper

This bot waits for @BlizzardCS to post a new Diablo 3 beta key and then activates it... before someone else does.

Also, model-based testing fun with rspec.

Ruby solution: `bin/d3-activate`

Shell script solution: `bin/simple-d3-activate`

## Blizzard's Contest

From Monday, April 9 through Friday, April 13 between the hours of 10 a.m. & 7 p.m. PDT, the @BlizzardCS Twitter account will post a series of Diablo III beta keys at random times throughout the week.

Announced here: http://us.battle.net/wow/en/forum/topic/4365748549

## Day 1
_Monday April 9_

The key G4JWYY-KPT9-RKGN8T-WY4G-WE24K9 was announced at 11:20am PDT. Our bot detected and posted the key succesfully, but the activation failed - someone else beat us to it.

The bot is running on a Small ec2 instance inside gnu screen. The key is scraped inside an eventmachine twitter-stream loop; the eventmachine then exits and the key is posted to battle.net/account using curl.

### Day 1 post-mortem
We were too slow. We scraped and posted the key, but someone else beat us to it :(. Let's measure and improve our speed.

### Day 1 action items
* record timestamps for key tweet, scrape, and post; the tweet timestamp will be from another clock, but might as well store it
* post the key immediately, instead of stopping eventmachine first
* maintain a logged-in battle.net/account session, instead of logging in, each time, before posting the key

### Day 1 follow-up
After the Day 1 action items, the key scrape-to-post time was reduced ~50% from ~3s to ~1-1.5s. These times are on a netbook over wifi on a Canadian isp ;), but should have a similar relative effect on ec2. Hopefully these upgrades will make the bot competitive tomorrow :).

## Day 2
_Tuesday April 10_

@BlizzardCS announced the key DBFHRD-KJJD-T4MCC4-7J7W-Z8CE87 at 10:30am PDT. Our bot was too slow.

Brainstorming sources of latency:

* curl resolving us.battle.net during key post... can we substitute the domain for the ip? no, it breaks the login cookies
* latency to twitter... can we get "closer" to the twitter stream? twitter's multi-datacenter architecture and ec2's tier 1 internet connection suggest a focus on our software and not network issues
* parsing JSON

### That's when it hit me

The biggest source of controllable latency is the ruby virtual machine and our bot's dependencies. Over-engineering is an easy mistake to repeat. The bot runs in a ruby vm with gems eventmachine, twitter-stream, and json. Super overkill.

The new implementation is three shell scripts totalling ~10 lines of logic (plus comments, output, and whitespace). One invocation of curl reads the stream, grep to filter, and curl (glued with xargs) to post the detected keys. Win. Maybe tomorrow we'll be competitive :).


