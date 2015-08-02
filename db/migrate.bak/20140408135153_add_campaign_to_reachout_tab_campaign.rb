class AddCampaignToReachoutTabCampaign < ActiveRecord::Migration
  def change
    add_column :reachout_tab_campaign, :campaign_id, :string
  end
end
