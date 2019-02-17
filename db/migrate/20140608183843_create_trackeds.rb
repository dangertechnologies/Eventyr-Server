class CreateTrackeds < ActiveRecord::Migration[5.2]
  def change
    create_table :trackeds do |t|
      t.references :user, index: true
      t.references :achievement, index: true
      t.boolean :pinned

      t.timestamps
    end
  end
end
