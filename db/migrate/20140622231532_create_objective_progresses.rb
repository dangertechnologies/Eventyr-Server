class CreateObjectiveProgresses < ActiveRecord::Migration[5.2]
  def change
    create_table :objective_progresses do |t|
      t.references :user, index: true
      t.references :objective, index: true
      t.boolean :completed
      t.integer :current_count

      t.timestamps
    end
  end
end
