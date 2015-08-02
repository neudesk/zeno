class AddIsAutoSignupToUser < ActiveRecord::Migration

  def self.up
    add_column :sys_user, :is_auto_signup, :boolean, :default => false
  end

  def self.down
    remove_column :sys_user, :is_auto_signup
  end

end
