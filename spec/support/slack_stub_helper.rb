def stub_slack_oauth(code: 'code', user_id: 'activated_user_id')
  stub_request(:post, 'https://slack.com/api/oauth.v2.access')
    .with(body: hash_including(code: code))
    .to_return(
      status: 200,
      body: {
        ok: true,
        access_token: 'token',
        bot_user_id: 'bot_user_id',
        team: { id: 'team_id', name: 'team_name' },
        authed_user: { id: user_id, access_token: 'user_token' }
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
end
