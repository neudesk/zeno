class AddColumnMetadataToDataGateway < ActiveRecord::Migration

  def self.up
    add_column :data_gateway, :metadata, :string
  end

  def self.down
    remove_column :data_gateway, :metadata
  end

end
