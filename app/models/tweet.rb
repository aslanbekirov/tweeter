require 'crate_ruby'
require 'time'

# Tweet class that talks to Crate
class Tweet
  include ActiveModel::Serialization
  
  client = CrateRuby::Client.new(CRATE_OPTIONS[:hosts])

  attr_accessor :id, :content, :created_at, :handle

  def avatar_url
    "//robohash.org/#{handle}.png?size=144x144&amp;bgset=bg2"
  end

  def attributes
    {'id' => id, 'content' => content, 'created_at' => created_at, 'handle' => handle}
  end

  def destroy
  client = CrateRuby::Client.new(CRATE_OPTIONS[:hosts])
  client.execute(
      'DELETE from tweeter.tweets WHERE id = ?',
      arguments: [@id])
  end

  def self.all(paged = false)
   client = CrateRuby::Client.new(CRATE_OPTIONS[:hosts])
  result = client.execute(
      'SELECT id, content, created_at, handle FROM tweeter.tweets ' \
      'WHERE kind = ? ORDER BY created_at DESC',
      arguments: ['tweet'],
      page_size: 25
    )
    result.map do |tweet|
      c = Tweet.new
      c.id, c.content, c.handle = tweet['id'], tweet['content'], tweet['handle']
      c.created_at = tweet['created_at'].to_time.utc.iso8601
      c
    end
  end

  def self.create(params)
   client = CrateRuby::Client.new(CRATE_OPTIONS[:hosts])
    c = Tweet.new
    c.id = SecureRandom.urlsafe_base64
    c.content = params[:content]
    crate_time = Time.now
    c.created_at = crate_time.to_time.utc.iso8601
    c.handle = params[:handle].downcase
    client.execute(
      'INSERT INTO tweeter.tweets (kind, id, content, created_at, handle) ' \
      'VALUES (?, ?, ?, ?, ?)',
      arguments: ['tweet', c.id, c.content, crate_time, c.handle])
    c
  end

  def self.find(id)
    tweet = client.execute(
      'SELECT id, content, created_at, handle FROM tweets WHERE id = ?',
      arguments: [id]).first
    c = Tweet.new
    c.id = tweet['id']
    c.content = tweet['content']
    c.created_at = tweet['created_at'].to_time.utc.iso8601
    c.handle = tweet['handle']
    c
  end
end
