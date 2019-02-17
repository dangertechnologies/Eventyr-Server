class CreateRegions < ActiveRecord::Migration[5.2]
  def change
    create_table :regions do |t|
      t.string :name
      t.references :continent, index: true

      t.timestamps
    end
  end
end
