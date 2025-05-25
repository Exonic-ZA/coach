RSpec.configure do |config|
  config.before do
    ENV['SLACK_CLIENT_ID']     = 'client_id'
    ENV['SLACK_CLIENT_SECRET'] = 'client_secret'
    ENV['SLACK_OAUTH_SCOPE']   = 'commands,chat:write,channels:read,groups:read,users:read,links:read,links:write'
    ENV['SLACK_REDIRECT_URI']  = 'https://coach.exonic.co.za/teams'
  end

  config.after do
    ENV.delete('SLACK_CLIENT_ID')
    ENV.delete('SLACK_CLIENT_SECRET')
    ENV.delete('SLACK_OAUTH_SCOPE')
    ENV.delete('SLACK_REDIRECT_URI')
  end
end
