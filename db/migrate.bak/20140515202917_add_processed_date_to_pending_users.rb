class AddProcessedDateToPendingUsers < ActiveRecord::Migration
  def change
    add_column :pending_users, :date_processed, :datetime
  end
end
