class CreateReachoutTabCampaign < ActiveRecord::Migration
  def change
    create_table :reachout_tab_campaign do |t|
      t.integer :gateway_id
      t.integer :did_e164 , :limit => 13
      t.boolean :generic_prompt
      t.datetime :schedule_start_date
      t.datetime :schedule_end_date
      t.timestamps
    end
  end
end
