class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.references :user, index: true
      t.references :from, index: true
      t.boolean :seen
      t.references :target, polymorphic: true, index: true

      t.timestamps
    end
  end
end
