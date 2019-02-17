class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles do |t|
      t.string :name
      t.text :description
      t.integer :permission_level
      t.string :img_path

      t.timestamps
    end
  end
end
