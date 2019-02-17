class AddKindToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :kind, :integer, index: true
  end
end
