class ChangeDefaultStatus < ActiveRecord::Migration
  def change
    remove_column :pending_users, :status
    add_column :pending_users, :status, :string, default: "unprocessed", after: :streaming_url
  end
end
