class AddOnAirScheduleToPendingUsers < ActiveRecord::Migration
  def change
    add_column :pending_users, :on_air_schedule, :string
    add_column :sys_user, :on_air_schedule, :string
  end
end
