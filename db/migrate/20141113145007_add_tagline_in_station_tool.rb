class AddTaglineInStationTool < ActiveRecord::Migration
  def self.up
    add_column :station_tool, :tagline, :string
  end

  def self.down
    remove_column :station_tool, :tagline
  end
end
