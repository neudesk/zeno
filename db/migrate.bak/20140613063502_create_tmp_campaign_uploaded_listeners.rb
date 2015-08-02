class CreateTmpCampaignUploadedListeners < ActiveRecord::Migration
  def change
    create_table :tmp_campaign_uploaded_listeners do |t|
      t.integer :ani_e164, :limit => 5
      t.integer :main_campaign_id

      t.timestamps
    end
  end
end
