class AddSignupDateToSysUser < ActiveRecord::Migration
  def change
    add_column :sys_user, :signup_date, :datetime
  end
end
