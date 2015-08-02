class AddCampaignSavedToReachoutTabCampaign < ActiveRecord::Migration
  def change
    add_column :reachout_tab_campaign, :campaign_saved, :boolean
  end
end
