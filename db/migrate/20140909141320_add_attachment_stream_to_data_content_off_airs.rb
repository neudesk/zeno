class AddAttachmentStreamToDataContentOffAirs < ActiveRecord::Migration
  def self.up
    change_table :data_content_off_air do |t|
      t.attachment :stream
    end
  end

  def self.down
    drop_attached_file :data_content_off_air, :stream
  end
end
