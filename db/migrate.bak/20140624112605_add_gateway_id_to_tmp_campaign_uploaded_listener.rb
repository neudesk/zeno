class AddGatewayIdToTmpCampaignUploadedListener < ActiveRecord::Migration
  def change
    add_column :tmp_campaign_uploaded_listeners, :gateway_id, :integer
  end
end
