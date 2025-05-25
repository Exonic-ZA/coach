require 'spec_helper'

describe 'Homepage', :js, type: :feature do
  before do
    ENV['SLACK_CLIENT_ID'] = 'client_id'
    ENV['SLACK_CLIENT_SECRET'] = 'client_secret'
    ENV['SLACK_OAUTH_SCOPE'] = 'scope:read'
    ENV['URL'] = 'http://localhost:5000'
    visit '/'
  end

  after do
    ENV.delete 'SLACK_CLIENT_ID'
    ENV.delete 'SLACK_CLIENT_SECRET'
    ENV.delete 'SLACK_OAUTH_SCOPE'
    ENV.delete 'URL'
  end

  it 'displays index.html page' do
    expect(title).to eq('Slava: Strava integration with Slack')
  end

  it 'includes a link to add to slack with the client id and correct scope' do
    expected_redirect_uri = CGI.escape("#{ENV.fetch('URL')}/slack/oauth/callback")
    expected_href = "https://slack.com/oauth/v2/authorize?scope=scope:read&client_id=client_id&redirect_uri=#{expected_redirect_uri}"

    expect(page).to have_css("a[href='#{expected_href}']")
  end
end
