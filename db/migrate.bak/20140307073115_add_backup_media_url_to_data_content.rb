class AddBackupMediaUrlToDataContent < ActiveRecord::Migration
  def change
    add_column :data_content, :backup_media_url, :string
  end
end
