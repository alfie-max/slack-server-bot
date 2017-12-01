ActiveRecord::Base.connection.data_sources
if ActiveRecord::Base.connection.data_source_exists? SlackIntegration.table_name
  require File.join(Rails.root, 'bot/init')
end
