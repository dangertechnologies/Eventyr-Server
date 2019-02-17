class CreateTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :types do |t|
      t.string :name
      t.text :description
      t.integer :points
      t.integer :icon, index: true
      t.date :time

      t.timestamps
    end
  end
end
