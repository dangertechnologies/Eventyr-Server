class CreateAchievementDependencies < ActiveRecord::Migration[5.2]
  def change
    create_table :achievement_dependencies do |t|
      t.references :achievement, index: true
      t.integer :dependency

      t.timestamps
    end
  end
end
