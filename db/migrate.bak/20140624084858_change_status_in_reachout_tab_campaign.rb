class ChangeStatusInReachoutTabCampaign < ActiveRecord::Migration
   def change
    change_column :reachout_tab_campaign, :status, :string
  end
end
