class AddOptInToDataGroupBroadcast < ActiveRecord::Migration
  def change
    add_column :data_group_broadcast, :opt_in_is_active, :boolean
  end
end
