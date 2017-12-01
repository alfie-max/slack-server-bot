require 'slack_bot_server/remote_control'

class SlackIntegration < ApplicationRecord
  after_create :add_to_slack_server

  private

  def add_to_slack_server
    queue = SlackBotServer::RedisQueue.new(redis: Redis.new)
    slack_remote = SlackBotServer::RemoteControl.new(queue: queue)
    slack_remote.add_bot(bot_access_token)
  end
end
