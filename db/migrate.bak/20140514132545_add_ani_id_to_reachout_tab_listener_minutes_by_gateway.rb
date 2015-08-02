class AddAniIdToReachoutTabListenerMinutesByGateway < ActiveRecord::Migration
  def change
    add_column :reachout_tab_listener_minutes_by_gateway, :listener_ani_id, :integer, :limit => 5
  end
end
