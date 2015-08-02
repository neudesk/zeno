class AddAttachmentLogoToDataGateways < ActiveRecord::Migration
  def change
    change_table :data_gateway do |t|
      t.attachment :logo
    end
  end
end
