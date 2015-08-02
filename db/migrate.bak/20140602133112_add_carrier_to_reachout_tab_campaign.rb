class AddCarrierToReachoutTabCampaign < ActiveRecord::Migration
  def change
    add_column :reachout_tab_campaign, :carrier_title, :string
  end
end
