class CreateModes < ActiveRecord::Migration[5.2]
  def change
    create_table :modes do |t|
      t.string :name
      t.text :description
      t.decimal :multiplier
      t.integer :icon, index: true
      t.date :time

      t.timestamps
    end
  end
end
