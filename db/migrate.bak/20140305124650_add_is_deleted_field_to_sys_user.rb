class AddIsDeletedFieldToSysUser < ActiveRecord::Migration
  def change
    add_column :sys_user, :is_deleted, :boolean
  end
end
