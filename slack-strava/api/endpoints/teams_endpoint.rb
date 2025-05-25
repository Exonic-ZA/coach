module Api
  module Endpoints
    class TeamsEndpoint < Grape::API
      format :json
      helpers Api::Helpers::CursorHelpers
      helpers Api::Helpers::SortHelpers
      helpers Api::Helpers::PaginationParameters

      namespace :teams do
        desc 'Get a team.'
        params do
          requires :id, type: String, desc: 'Team ID.'
        end
        get ':id' do
          team = Team.where(_id: params[:id], api: true).first || error!('Not Found', 404)
          present team, with: Api::Presenters::TeamPresenter
        end

        desc 'Get all the teams.'
        params do
          optional :active, type: Boolean, desc: 'Return active teams only.'
          use :pagination
        end
        sort Team::SORT_ORDERS
        get do
          teams = Team.api
          teams = teams.active if params[:active]
          teams = paginate_and_sort_by_cursor(teams, default_sort_order: '-_id')
          present teams, with: Api::Presenters::TeamsPresenter
        end

        desc 'Create a team using an OAuth token.'
        params do
          requires :code, type: String
        end
        post do
          unless ENV.key?('SLACK_CLIENT_ID') && ENV.key?('SLACK_CLIENT_SECRET') && ENV.key?('SLACK_REDIRECT_URI')
            raise 'Missing required Slack OAuth env vars.'
          end

          conn = Faraday.new(url: 'https://slack.com') do |f|
            f.request :url_encoded
            f.adapter Faraday.default_adapter
          end

          response = conn.post('/api/oauth.v2.access', {
            client_id: ENV['SLACK_CLIENT_ID'],
            client_secret: ENV['SLACK_CLIENT_SECRET'],
            code: params[:code],
            redirect_uri: ENV['SLACK_REDIRECT_URI']
          })

          rc = JSON.parse(response.body)

          if !rc['ok']
            error! rc['error'], 400
          end

          # New format
          access_token = rc['access_token']
          bot_user_id = rc.dig('bot_user_id') || rc.dig('bot', 'bot_user_id')
          team_id = rc['team']['id']
          team_name = rc['team']['name']
          user_id = rc.dig('authed_user', 'id')

          team = Team.where(team_id: team_id).first

          if team
            team.ping_if_active!
            team.update!(
              token: access_token,
              activated_user_id: user_id,
              activated_user_access_token: rc.dig('authed_user', 'access_token'),
              bot_user_id: bot_user_id
            )
            raise "Team #{team.name} is already registered." if team.active?
            team.activate!(access_token)
          else
            team = Team.create!(
              token: access_token,
              team_id: team_id,
              name: team_name,
              activated_user_id: user_id,
              activated_user_access_token: rc.dig('authed_user', 'access_token'),
              bot_user_id: bot_user_id
            )
          end

          SlackRubyBotServer::Service.instance.create!(team)
          present team, with: Api::Presenters::TeamPresenter
        end
      end
    end
  end
end
