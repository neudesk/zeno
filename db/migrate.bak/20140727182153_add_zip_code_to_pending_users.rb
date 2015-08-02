class AddZipCodeToPendingUsers < ActiveRecord::Migration
  def change
    add_column :pending_users, :zip_code, :string
  end
end
