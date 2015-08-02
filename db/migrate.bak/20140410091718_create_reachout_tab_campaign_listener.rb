class CreateReachoutTabCampaignListener < ActiveRecord::Migration
  def change
    create_table :reachout_tab_campaign_listener do |t|
      t.integer :campaign_id
      t.string :phone_number
      t.datetime :campaign_date

      t.timestamps
    end
  end
end
