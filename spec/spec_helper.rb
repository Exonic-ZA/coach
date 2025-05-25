$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'fabrication'
require 'faker'
require 'hyperclient'
require 'webmock/rspec'

# Load env helper before any specs run
require_relative 'support/env_helper'
require_relative 'support/slack_stub_helper'

ENV['RACK_ENV'] = 'test'

require 'slack-ruby-bot/rspec'
require 'slack-strava'

# Load remaining support files (excluding env_helper to avoid double-require)
Dir[File.join(File.dirname(__FILE__), 'support', '**/*.rb')].sort.each do |file|
  require file unless file.include?('env_helper.rb')
end
