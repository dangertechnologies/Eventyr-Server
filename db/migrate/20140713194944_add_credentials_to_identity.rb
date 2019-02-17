class AddCredentialsToIdentity < ActiveRecord::Migration[5.2]
  def change
    add_column :identities, :token, :text
    add_column :identities, :token_expires, :timestamp
  end
end
