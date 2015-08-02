class AddSignupDateToPendingUsers < ActiveRecord::Migration
  def change
    remove_column :sys_user, :signup_date
    add_column :pending_users, :signup_date, :datetime, after: :country
  end
end
