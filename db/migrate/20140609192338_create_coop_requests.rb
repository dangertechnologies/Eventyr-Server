class CreateCoopRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :coop_requests do |t|
      t.references :user, index: true
      t.references :target, index: true
      t.references :achievement, index: true
      t.references :list, index: true
      t.boolean :pending
      t.boolean :complete

      t.timestamps
    end
  end
end
