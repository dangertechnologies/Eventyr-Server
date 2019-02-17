class AddHashToAchievements < ActiveRecord::Migration[5.2]
  def change
    add_column :achievements, :hash_identifier, :string
  end
end
