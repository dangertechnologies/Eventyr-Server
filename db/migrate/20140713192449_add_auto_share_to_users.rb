class AddAutoShareToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :auto_share, :boolean
  end
end
