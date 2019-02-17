class CreateVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :votes do |t|
      t.references :achievement, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :value

      t.timestamps
    end

    add_column :achievements, :upvotes, :integer, index: true
    add_column :achievements, :downvotes, :integer, index: true
  end
end
