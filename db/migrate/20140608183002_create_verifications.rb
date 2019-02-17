class CreateVerifications < ActiveRecord::Migration[5.2]
  def change
    create_table :verifications do |t|
      t.references :user, index: true

      t.timestamps
    end
  end
end
