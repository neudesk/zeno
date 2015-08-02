class AddCustomFieldsToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :trackable_title, :string
    add_column :activities, :user_title, :string
    add_column :activities, :sec_trackable_type, :string
    add_column :activities, :sec_trackable_title, :string
  end
end
