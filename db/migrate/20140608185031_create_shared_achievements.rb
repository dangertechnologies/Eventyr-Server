class CreateSharedAchievements < ActiveRecord::Migration[5.2]
  def change
    create_table :shared_achievements do |t|
      t.references :achievement, index: true
      t.references :user, index: true
      t.boolean :request_coop
      t.boolean :can_invite
      t.integer :target_id, index: true

      t.timestamps
    end
  end
end
