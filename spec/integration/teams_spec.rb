require 'spec_helper'

describe 'Teams', :js, type: :feature do
  before do
    stub_slack_oauth(user_id: 'activated_user_id')

    allow_any_instance_of(Slack::Web::Client).to receive(:conversations_open).with(
      users: 'activated_user_id'
    ).and_return('channel' => { 'id' => 'C1' })

    allow_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage)
    allow(SlackRubyBotServer::Service.instance).to receive(:create!)
    allow_any_instance_of(Team).to receive(:ping!).and_return(ok: true)
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
