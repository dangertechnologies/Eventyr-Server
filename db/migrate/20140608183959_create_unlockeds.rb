class CreateUnlockeds < ActiveRecord::Migration[5.2]
  def change
    create_table :unlockeds do |t|
      t.integer :points
      t.integer :coop_bonus
      t.references :user, index: true
      t.references :achievement, index: true
      t.boolean :coop
      t.references :verification, index: true

      t.timestamps
    end
  end
end
