class CreateDataCarrierRule < ActiveRecord::Migration
  def self.up
    create_table :data_carrier_rule do |t|
      t.integer :parent_carrier_id
      t.integer :gateway_id
      t.integer :entryway_provider_id
      t.integer :gateway_prompt_id
      t.boolean :hangup_after_play, default: true
      t.boolean :is_enabled, default: true
      t.timestamps
    end
  end
  def self.down
    drop_table :data_carrier_rule
  end
end
