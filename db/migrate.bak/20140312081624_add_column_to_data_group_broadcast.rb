class AddColumnToDataGroupBroadcast < ActiveRecord::Migration
  def change
    add_column :data_group_broadcast, :reachout_tab_is_active, :boolean
  end
end
