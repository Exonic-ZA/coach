require 'spec_helper'

describe 'Teams', :js, type: :feature do
  before do
    ENV['SLACK_CLIENT_ID'] = 'client_id'
    ENV['SLACK_CLIENT_SECRET'] = 'client_secret'
    ENV['SLACK_OAUTH_SCOPE'] = 'bot,commands,links:read,links:write'
    ENV['SLACK_REDIRECT_URI'] = 'https://coach.exonic.co.za/teams'
  end

  after do
    ENV.delete 'SLACK_CLIENT_ID'
    ENV.delete 'SLACK_CLIENT_SECRET'
    ENV.delete 'SLACK_OAUTH_SCOPE'
    ENV.delete 'SLACK_REDIRECT_URI'
  end

  context 'oauth', vcr: { cassette_name: 'auth_test' } do
    it 'registers a team' do
      # Stub the Faraday POST to Slack's v2 OAuth endpoint
      slack_response = {
        ok: true,
        access_token: 'token',
        bot_user_id: 'bot_user_id',
        team: {
          id: 'team_id',
          name: 'team_name'
        },
        authed_user: {
          id: 'user_id',
          access_token: 'user_token'
        }
      }.to_json

      stub_request(:post, "https://slack.com/api/oauth.v2.access")
        .to_return(status: 200, body: slack_response, headers: { 'Content-Type' => 'application/json' })

      allow_any_instance_of(Team).to receive(:ping!).and_return(ok: true)
      expect(SlackRubyBotServer::Service.instance).to receive(:create!)

      expect {
        visit '/?code=code'
        expect(page.find_by_id('messages')).to have_content 'Team successfully registered!'
      }.to change(Team, :count).by(1)
    end
  end
end
