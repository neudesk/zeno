class AddCreatedByToReachoutTabCampaign < ActiveRecord::Migration
  def change
    add_column :reachout_tab_campaign, :created_by, :integer
  end
end
