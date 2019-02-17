class AddAllowCoopToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :allow_coop, :boolean
  end
end
