class CreateLists < ActiveRecord::Migration[5.2]
  def change
    create_table :lists do |t|
      t.string :title
      t.references :user, index: true
      t.boolean :is_public, default: false

      t.timestamps
    end
  end
end
