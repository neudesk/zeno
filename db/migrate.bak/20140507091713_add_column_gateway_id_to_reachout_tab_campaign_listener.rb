class AddColumnGatewayIdToReachoutTabCampaignListener < ActiveRecord::Migration
  def change
    add_column :reachout_tab_campaign_listener, :gateway_id, :integer
  end
end
