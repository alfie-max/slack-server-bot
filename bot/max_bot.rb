require 'slack_bot_server/bot'

class SlackBotServer::MaxBot < SlackBotServer::Bot
  username ENV['SLACK_BOT_NAME'] || 'Hello Bot'
  # icon_url 'http://my.server.example.com/assets/icon.png'

  on_mention do |data|
    if data['message'] == 'who are you?'
      reply text: "I am #{bot_user_name} (user id: #{bot_user_id}), connected to team #{team_name} with Team ID : #{team_id}"
    else
      reply text: "You said '#{data['message']}', and I'm frankly fascinated."
    end
  end

  on_im do |data|
    if data['message'] == 'who are you?'
      reply text: "I am #{bot_user_name} (user id: #{bot_user_id}), connected to team #{team_name} with Team ID : #{team_id}"
    else
      reply text: "Hmm, OK, let me get back to you about that."
    end
  end
end
