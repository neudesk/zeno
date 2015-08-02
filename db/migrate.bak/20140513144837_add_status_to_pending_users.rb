class AddStatusToPendingUsers < ActiveRecord::Migration
  def change
    add_column :pending_users, :status, :string, default: "unprocessed", after: :streaming_url
    add_index :pending_users, :status
  end
end
