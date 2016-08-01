class AddTokenToUser < ActiveRecord::Migration
  def up
  	add_column :users, :token, :string
  end

  def down
    remove_column :users, :token, :string
  end
end
