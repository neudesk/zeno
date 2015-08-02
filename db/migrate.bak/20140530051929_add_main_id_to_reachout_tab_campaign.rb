class AddMainIdToReachoutTabCampaign < ActiveRecord::Migration
  def change
    add_column :reachout_tab_campaign, :main_id, :integer
  end
end
