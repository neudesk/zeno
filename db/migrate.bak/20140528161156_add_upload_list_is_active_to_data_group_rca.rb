class AddUploadListIsActiveToDataGroupRca < ActiveRecord::Migration
  def change
    add_column :data_group_rca, :upload_list_is_active, :boolean
  end
end
