require 'bundler/setup'
Bundler.require
require 'mastodon'
require 'sanitize'
require 'yaml'
config = YAML.load_file("./config.yml")

stream = Mastodon::Streaming::Client.new(
  base_url: "https://" + config["mstdn_base_url"],
  bearer_token: config["mstdn_access_token"])

tw = Twitter::REST::Client.new do |key|
  key.consumer_key = config["tw_consumer_key"]
  key.consumer_secret = config["tw_consumer_secret"]
  key.access_token = config["tw_access_token"]
  key.access_token_secret = config["tw_access_token_secret"]
end

path = "public/local"
tag = config["tag"]
begin
  stream.stream(path) do |toot|
    next if !toot.kind_of?(Mastodon::Status)
    if Sanitize.clean(toot.content).include?(tag) then
      tw.update(toot.account.acct + ":" + Sanitize.clean(toot.content) + toot.url)
    end
  end
rescue => e
  puts e
  retry
end
