class AddLogoOnStationTool < ActiveRecord::Migration
  def self.up
    add_column :station_tool, :logo_file_name, :string
    add_column :station_tool, :logo_file_size, :integer
    add_column :station_tool, :logo_content_type, :string
    add_column :station_tool, :logo_updated_at, :datetime
  end
end
