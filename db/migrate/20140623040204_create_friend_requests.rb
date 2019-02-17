class CreateFriendRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :friend_requests do |t|
      t.references :user, index: true
      t.references :to, index: true
      t.string :message

      t.timestamps
    end
  end
end
