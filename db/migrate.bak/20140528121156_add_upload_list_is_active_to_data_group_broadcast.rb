class AddUploadListIsActiveToDataGroupBroadcast < ActiveRecord::Migration
  def change
    add_column :data_group_broadcast, :upload_list_is_active, :boolean
  end
end
