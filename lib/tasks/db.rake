require 'crate_ruby'

namespace :crate do
  desc "TODO"
  task :setup => :environment do
    session = CrateRuby::Client.new(CRATE_OPTIONS[:hosts])

    session.execute(
      "CREATE TABLE IF NOT EXISTS tweeter.tweets ( \
          kind string primary key, \
          id string, \
          content string, \
          created_at timestamp primary key, \
          handle string \
      )"
    )
    session.execute(
      "CREATE TABLE IF NOT EXISTS tweeter.analytics ( \
          kind string primary key, \
          key string, \
          frequency integer primary key \
      )"
    )
  end
end
