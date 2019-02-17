class AddHashToObjectives < ActiveRecord::Migration[5.2]
  def change
    add_column :objectives, :hash_identifier, :string
  end
end
