require 'crate_ruby'
require 'time'

# Tweet class that talks to Crate
class Tweet
  include ActiveModel::Serialization

  @client = CrateRuby::Client.new(CRATE_OPTIONS[:hosts])

  attr_accessor :id, :content, :created_at, :handle

  def avatar_url
    "//robohash.org/#{handle}.png?size=144x144&amp;bgset=bg2"
  end

  def attributes
    { 'id' => id, 'content' => content, 'created_at' => created_at, 'handle' => handle }
  end

  def destroy
    client.execute(
      'DELETE from tweeter.tweets WHERE id = ?',
      [@id]
    )
  end

  def self.all(_paged = false)
    result = @client.execute(
      'SELECT id, content, date_format(created_at), handle FROM tweeter.tweets ' \
      'WHERE kind = ? ORDER BY created_at DESC',
      ['tweet']
    )
    result.map do |tweet|
      c = Tweet.new
      c.id, c.content, c.handle = tweet[0], tweet[1], tweet[3]
      c.created_at = tweet[2].to_time.utc.iso8601
      c
    end
  end

  def self.create(params)
    c = Tweet.new
    c.id = SecureRandom.urlsafe_base64
    c.content = params[:content]
    c.created_at = Time.now.to_time.utc.iso8601
    c.handle = params[:handle].downcase
    @client.execute(
      'INSERT INTO tweeter.tweets (kind, id, content, created_at, handle) ' \
      'VALUES (?, ?, ?, ?, ?)',
      ['tweet', c.id, c.content, c.created_at, c.handle])
    c
  end

  def self.find(id)
    tweet = @client.execute(
      'SELECT id, content, date_format(created_at), handle FROM tweets WHERE id = ?',
      [id]).first
    c = Tweet.new
    c.id, c.content, c.handle = tweet[0], tweet[1], tweet[3]
    c.created_at = tweet[2].to_time.utc.iso8601
    c
  end
end
