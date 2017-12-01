class CreateSlackIntegrations < ActiveRecord::Migration[5.1]
  def change
    create_table :slack_integrations do |t|
      t.string :team_id
      t.string :team_name
      t.string :user_id
      t.string :access_token
      t.string :bot_user_id
      t.string :bot_access_token

      t.timestamps
    end
  end
end
