class CreateFollowedLists < ActiveRecord::Migration[5.2]
  def change
    create_table :followed_lists do |t|
      t.references :list, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
