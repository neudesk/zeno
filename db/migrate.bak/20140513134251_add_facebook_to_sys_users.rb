class AddFacebookToSysUsers < ActiveRecord::Migration
  def change
    add_column :sys_user, :facebook, :string
    add_column :sys_user, :twitter, :string
    add_column :sys_user, :address, :string
    add_column :sys_user, :city, :string
    add_column :sys_user, :state, :string
  end
end
