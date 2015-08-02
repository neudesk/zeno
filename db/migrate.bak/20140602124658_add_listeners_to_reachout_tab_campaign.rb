class AddListenersToReachoutTabCampaign < ActiveRecord::Migration
  def change
    add_column :reachout_tab_campaign, :listeners_no, :integer
    add_column :reachout_tab_campaign, :did_provider, :string
  end
end
