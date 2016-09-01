require 'crate_ruby'
require 'time'

# Tweet class that talks to Crate
class Analytics
  @client = CrateRuby::Client.new(CRATE_OPTIONS[:hosts])

  attr_accessor :key, :frequency

  def self.all(_paged = false)

    results = @client.execute("SELECT key, frequency FROM tweeter.analytics WHERE kind='tweet' ORDER BY frequency DESC")
    results.map do |a|
      c = Analytics.new
      c.key, c.frequency = a[0], a[1]
      c
    end
   end
end
