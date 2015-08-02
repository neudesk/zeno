class DataParentCarrier < ActiveRecord::Base
  attr_accessible :title
  has_many :data_carrier_rule
  validates :title, presence: true, uniqueness: true
end
