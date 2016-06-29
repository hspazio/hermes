class AddUserToFeeds < ActiveRecord::Migration
  def up
  	add_column :feeds, :user_id, :integer, after: :name
    add_foreign_key :feeds, :users
    add_index :feeds, :user_id
  end

  def down
  	remove_index :feeds, :user_id
  	remove_foreign_key :feeds, :users
    remove_column :feeds, :user_id
  end
end
