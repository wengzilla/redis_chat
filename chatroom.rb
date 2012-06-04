require 'rubygems'
require 'redis'
require 'json'
require 'hashie'

class ChatClient

  attr_accessor :address, :channel, :username

  def initialize(address, channel, username)
    @address = address
    @channel = channel
    @username = username
  end

  def send(message)
    redis.publish(channel, {message: message, user: username}.to_json)
  end

  def redis
    @redis ||= Redis.new(:host => address, :port => 6379)    
  end

  def subscribe
    redis.subscribe(channel) do |on|
      on.message do |room, msg|
        data = Hashie::Mash.new(JSON.parse(msg))
        puts "##{room} #{data.user}: - #{data.message}"
      end
    end
  end

end

