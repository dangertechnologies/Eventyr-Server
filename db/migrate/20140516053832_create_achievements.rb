class CreateAchievements < ActiveRecord::Migration[5.2]
  def change
    create_table :achievements do |t|
      t.string :name
      t.string :short_description
      t.text :full_description
      t.integer :base_points
      t.date :expires
      t.boolean :has_parents
      t.boolean :is_multiplayer
      t.boolean :is_global
      t.boolean :is_suggested_global
      t.references :user, index: true
      t.integer :kind, index: true
      t.integer :icon, index: true
      t.references :category, index: true
      t.integer :mode, index: true

      t.timestamps
    end
  end
end
