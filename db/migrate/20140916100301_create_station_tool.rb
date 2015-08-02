class CreateStationTool < ActiveRecord::Migration
  def change
    create_table :station_tool do |t|
      t.string :tool_type
      t.string :player_type
      t.string :station_name
      t.text  :station_description
      t.string :station_website
      t.string :phone_number_display
      t.string :did
      t.boolean :is_auto_play, :default => false
      t.string :channel_to_auto_play
      t.string :player_height
      t.string :player_width
      t.float :player_volume
      t.string  :logo
      t.timestamps
    end
  end
end
