require 'crate_ruby'
require 'time'

# Tweet class that talks to Crate
class Analytics
 def self.all(paged = false)
  client = CrateRuby::Client.new

  results = client.execute("Select key, frequency FROM tweeter.analytics where kind='tweet' ORDER BY frequency DESC")
  results.map do |anal|
      c = Analytics.new
      c.key, c.frequency = anal['key'], anal['frequency']
      c
    end
  end
end
