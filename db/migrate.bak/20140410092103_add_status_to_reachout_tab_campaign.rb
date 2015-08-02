class AddStatusToReachoutTabCampaign < ActiveRecord::Migration
  def change
    add_column :reachout_tab_campaign, :status, :boolean
  end
end
