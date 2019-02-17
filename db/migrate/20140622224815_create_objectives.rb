class CreateObjectives < ActiveRecord::Migration[5.2]
  def change
    create_table :objectives do |t|
      t.string :tagline
      t.integer :base_points
      t.integer :required_count
      t.boolean :is_public, default: false
      t.integer :kind, index: true

      t.integer :time_constraint, index: true, null: true
      t.datetime :from_timestamp, index: true
      t.datetime :to_timestamp, index: true

      t.float :lat
      t.float :lng
      t.float :alt
      t.references :country, index: true
    
      t.timestamps
    end
    add_index :objectives, [:lat, :lng]
    add_index :objectives, [:lng, :lat]
  end
end
