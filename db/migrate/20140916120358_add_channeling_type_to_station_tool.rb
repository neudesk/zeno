class AddChannelingTypeToStationTool < ActiveRecord::Migration

  def self.up
    remove_column :station_tool, :player_type
    add_column :station_tool, :channeling_type, :string, :default => 'single'
    add_column :station_tool, :is_customized, :boolean, :default => false
  end

  def self.down
    add_column :station_tool, :player_type, :string
    remove_column :station_tool, :channeling_type
    remove_column :station_tool, :is_customized
  end

end
