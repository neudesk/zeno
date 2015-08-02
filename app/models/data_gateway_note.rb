class DataGatewayNote < ActiveRecord::Base
  include PublicActivity::Model

  attr_accessible :user_id, :gateway_id, :note, :is_deleted
  belongs_to :data_gateway, foreign_key: :gateway_id
  belongs_to :user, foreign_key: :user_id

  validates :note, presence: true
end
