class AddCellphoneToPendingUsers < ActiveRecord::Migration
  def change
    remove_column :pending_users, :phone
    add_column :pending_users, :cellphone, :string
    add_column :pending_users, :landline, :string
  end
end
