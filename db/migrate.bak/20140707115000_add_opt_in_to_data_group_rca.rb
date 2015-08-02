class AddOptInToDataGroupRca < ActiveRecord::Migration
  def change
    add_column :data_group_rca, :opt_in_is_active, :boolean
  end
end
