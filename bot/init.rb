require 'slack_bot_server'
require 'slack_bot_server/redis_queue'
require 'slack_bot_server/simple_bot'

# Use a Redis-based queue to add/remove bots and to trigger
# bot messages to be sent
queue = SlackBotServer::RedisQueue.new

# Create a new server using that queue
server = SlackBotServer::Server.new(queue: queue)

# How your application-specific should be created when the server
# is told about a new slack api token to connect with
server.on_add do |token|
  # Return a new bot instance to the server. `SimpleBot` is a provided
  # example bot with some very simple behaviour.
  SlackBotServer::SimpleBot.new(token: token)
end

SlackIntegration.all.each do |integration|
  # Any arguments can be passed to the `add_bot` method; they are passed
  # on to the proc supplied to `on_add` for the server.
  server.add_bot(integration.bot_access_token, integration.team_id)
end

# Actually start the server. This line is blocking; code after
# it won't be executed.

Thread.abort_on_exception = true

Thread.new do
  server.start
end
