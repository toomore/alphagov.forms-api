class CreateAccessTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :access_tokens do |t|
      t.string :token
      t.string :owner
      t.datetime :deactivated_at
      t.timestamps
    end
  end
end
