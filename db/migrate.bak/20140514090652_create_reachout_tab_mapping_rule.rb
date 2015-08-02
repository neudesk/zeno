class CreateReachoutTabMappingRule < ActiveRecord::Migration
  def change
    create_table :reachout_tab_mapping_rule do |t|
      t.integer :carrier_id, :limit => 5
      t.string :carrier_title
      t.integer :entryway_id, :limit => 5
      t.string :entryway_provider
      t.timestamps
    end
  end
end
