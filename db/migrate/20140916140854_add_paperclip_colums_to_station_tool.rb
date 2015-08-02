class AddPaperclipColumsToStationTool < ActiveRecord::Migration
  def self.up
    remove_column :station_tool, :logo
    add_column :station_tool, :background_file_name, :string
    add_column :station_tool, :background_file_size, :integer
    add_column :station_tool, :background_content_type, :string
    add_column :station_tool, :background_updated_at, :datetime
  end
end
