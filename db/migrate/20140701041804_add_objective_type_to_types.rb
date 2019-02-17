class AddObjectiveTypeToTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :types, :objective_type, :boolean
  end
end
