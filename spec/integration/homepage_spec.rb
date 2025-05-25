describe 'Homepage', :js, type: :feature do
  before do
    ENV['SLACK_CLIENT_ID'] = 'client_id'
    ENV['SLACK_CLIENT_SECRET'] = 'client_secret'
    ENV['SLACK_OAUTH_SCOPE'] = 'commands,chat:write,channels:read,groups:read,users:read,links:read,links:write'
    ENV['SLACK_REDIRECT_URI'] = 'https://coach.exonic.co.za/teams'
    visit '/'
  end

  after do
    ENV.delete 'SLACK_CLIENT_ID'
    ENV.delete 'SLACK_CLIENT_SECRET'
    ENV.delete 'SLACK_OAUTH_SCOPE'
    ENV.delete 'SLACK_REDIRECT_URI'
  end

  it 'displays index.html page' do
    expect(title).to eq('Slava: Strava integration with Slack')
  end

  it 'includes a link to add to slack with the client id and correct scope' do
    expected_scope = ENV.fetch('SLACK_OAUTH_SCOPE')
    expected_client_id = ENV.fetch('SLACK_CLIENT_ID')
    expected_redirect_uri = ENV.fetch('SLACK_REDIRECT_URI')

    expected_href = "https://slack.com/oauth/v2/authorize?scope=#{expected_scope}&client_id=#{expected_client_id}&redirect_uri=#{expected_redirect_uri}"

    expect(page).to have_link(href: expected_href)
  end
end
