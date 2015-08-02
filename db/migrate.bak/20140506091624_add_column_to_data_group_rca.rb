class AddColumnToDataGroupRca < ActiveRecord::Migration
  def change
    add_column :data_group_rca, :reachout_tab_is_active, :boolean
  end
end
