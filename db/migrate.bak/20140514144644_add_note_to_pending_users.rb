class AddNoteToPendingUsers < ActiveRecord::Migration
  def change
    add_column :pending_users, :note, :text, after: :signup_date
  end
end
