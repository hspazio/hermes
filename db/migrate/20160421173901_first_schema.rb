class FirstSchema < ActiveRecord::Migration
  def change
  	create_table :users do |t|
      t.string :username
      t.string :password_digest
    end

    create_table :feeds do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :subscriptions do |t|
      t.integer :feed_id, index: true
      t.integer :user_id, index: true
      t.string :callback_url
      t.timestamps null: false
    end

    create_table :messages do |t|
      t.integer :feed_id, index: true
      t.integer :user_id, index: true
      t.string :data
      t.timestamp :created_at, null: false
    end
  end
end
