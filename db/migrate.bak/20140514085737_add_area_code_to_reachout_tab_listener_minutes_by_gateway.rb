class AddAreaCodeToReachoutTabListenerMinutesByGateway < ActiveRecord::Migration
  def change
    add_column :reachout_tab_listener_minutes_by_gateway, :carrier_id, :integer, :limit => 5
    add_column :reachout_tab_listener_minutes_by_gateway, :carrier_title, :string

  end
end
