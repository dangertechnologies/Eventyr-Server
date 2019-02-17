class CreateTitles < ActiveRecord::Migration[5.2]
  def change
    create_table :titles do |t|
      t.string :name
      t.references :achievement, index: true
      t.integer :points

      t.timestamps
    end
  end
end
