class AddAffiliateToPendingUser < ActiveRecord::Migration
  def change
    add_column :pending_users, :affiliate, :string
    add_column :pending_users, :rca, :string
    add_column :pending_users, :enabled, :boolean, default: true
  end
end
