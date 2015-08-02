class AddTagToUser < ActiveRecord::Migration
  def change
    add_column :sys_user, :tags, :text
  end
end
