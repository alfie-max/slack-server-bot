class SlackController < ApplicationController
  def install
  end

  def oauth
    if params['code']
      slack_client = Slack::Web::Client.new
      response = slack_client.oauth_access(
        code: params['code'],
        client_id: ENV['SLACK_CLIENT_ID'],
        client_secret: ENV['SLACK_CLIENT_SECRET'],
        redirect_uri: slack_oauth_url
      )
      if response['ok']
        team = SlackIntegration.find_or_create_by(team_id: response['team_id'])
        team.update_attributes(
          team_name: response['team_name'],
          user_id: response['user_id'],
          access_token: response['access_token'],
          bot_user_id: response['bot']['bot_user_id'],
          bot_access_token: response['bot']['bot_access_token']
        )
        redirect_to root_path
      else
        # there was a failure; check in the response
      end
    else
      redirect_to root_path
    end
  end
end
