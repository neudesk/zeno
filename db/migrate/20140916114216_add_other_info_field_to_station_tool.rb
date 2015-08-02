class AddOtherInfoFieldToStationTool < ActiveRecord::Migration
  def self.up
    add_column :station_tool, :additional_info, :string
  end

  def self.down
    remove_column :station_tool, :additional_info
  end
end
