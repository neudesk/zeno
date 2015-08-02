class UserCountry < ActiveRecord::Base
  self.table_name = :sys_user_countries

  belongs_to :user
  belongs_to :country, class_name: "DataGroupCountry", foreign_key: :country_id

  attr_accessible :user_id, :country_id
end