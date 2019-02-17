class CreateSharedLists < ActiveRecord::Migration[5.2]
  def change
    create_table :shared_lists do |t|
      t.references :list, index: true
      t.references :user, index: true
      t.boolean :request_coop
      t.boolean :can_invite
      t.boolean :is_collaborative
      t.integer :target_id, index: true

      t.timestamps
    end
  end
end
