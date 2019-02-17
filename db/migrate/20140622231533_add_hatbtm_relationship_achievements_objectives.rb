class AddHatbtmRelationshipAchievementsObjectives < ActiveRecord::Migration[5.2]
  def change
    create_table :achievements_objectives, id: false do |t|
        t.belongs_to :objective
        t.belongs_to :achievement
    end
  end
end
