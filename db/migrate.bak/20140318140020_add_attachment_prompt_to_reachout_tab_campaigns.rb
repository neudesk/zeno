class AddAttachmentPromptToReachoutTabCampaigns < ActiveRecord::Migration
  def change
    change_table :reachout_tab_campaign do |t|
      t.attachment :prompt
    end
  end
end
