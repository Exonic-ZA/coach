require 'spec_helper'

describe 'Teams', :js, type: :feature do
  let(:slack_response) do
    {
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
  end

  before do
    stub_request(:post, 'https://slack.com/api/oauth.v2.access')
      .with(body: hash_including(code: 'code'))
      .to_return(status: 200, body: slack_response, headers: { 'Content-Type' => 'application/json' })

    allow_any_instance_of(Slack::Web::Client).to receive(:conversations_open).with(users: 'user_id').and_return(
      'channel' => { 'id' => 'C1' }
    )

    allow_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage)
    allow(SlackRubyBotServer::Service.instance).to receive(:create!)
    allow_any_instance_of(Team).to receive(:ping!).and_return(ok: true)
  end

  after do
    ENV.delete 'SLACK_CLIENT_ID'
    ENV.delete 'SLACK_CLIENT_SECRET'
    ENV.delete 'SLACK_OAUTH_SCOPE'
    ENV.delete 'SLACK_REDIRECT_URI'
  end

  context 'oauth', vcr: { cassette_name: 'auth_test' } do
    it 'registers a team' do
      expect {
        visit '/?code=code'
        expect(page.find_by_id('messages')).to have_content 'Team successfully registered!'
      }.to change(Team, :count).by(1)
    end
  end
end
