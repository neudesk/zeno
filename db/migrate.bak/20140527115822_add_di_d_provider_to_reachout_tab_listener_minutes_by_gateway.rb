class AddDiDProviderToReachoutTabListenerMinutesByGateway < ActiveRecord::Migration
  def change
    add_column :reachout_tab_listener_minutes_by_gateway, :did_title, :string
  end
end
