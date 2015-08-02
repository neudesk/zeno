class ChangeColumnMediaType < ActiveRecord::Migration
  def change
    change_column :data_content, :media_type, 'char(16)', :default => 'FFMPEG'
  end
end
