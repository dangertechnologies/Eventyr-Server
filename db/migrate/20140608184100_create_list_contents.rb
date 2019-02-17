class CreateListContents < ActiveRecord::Migration[5.2]
  def change
    create_table :list_contents do |t|
      t.references :list, index: true
      t.references :achievement, index: true

      t.timestamps
    end
  end
end
