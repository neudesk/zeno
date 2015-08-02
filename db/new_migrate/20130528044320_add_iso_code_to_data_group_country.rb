class AddIsoCodeToDataGroupCountry < ActiveRecord::Migration
  def change
    add_column :data_group_country, :iso_code, :string
  end
end
