class AddProfileToImage < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :profile_picture, :boolean
  end
end
