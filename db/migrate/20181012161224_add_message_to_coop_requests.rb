class AddMessageToCoopRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :coop_requests, :message, :string
  end
end
