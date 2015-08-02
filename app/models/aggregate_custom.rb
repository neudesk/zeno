class AggregateCustom < ActiveRecord::Base
  REMOVE = 'remove'
  attr_accessible :removable_id, :removable_type, :remove_children
  belongs_to :user
  belongs_to :removable, :polymorphic => true

  validates :user_id, :removable_id, :removable_type, :presence => true
  validates :user_id, :uniqueness => { :scope => [:removable_id, :removable_type]}
  scope :by_type, lambda { |type| where(removable_type: type) }
  scope :only_countries, by_type(DataGroupCountry)
  scope :only_gateways, by_type(DataGateway)
  scope :only_contents, by_type(DataContent)
  scope :only_entryways, by_type(DataEntryway)
  scope :with_remove_children, where(remove_children: true)
  scope :without_remove_children, where(remove_children: false)

  # get ids from parents
  scope :get_gateway_ids, joins("INNER JOIN data_gateway ON data_gateway.country_id = aggregate_custom.removable_id AND aggregate_custom.removable_type = 'DataGroupCountry'").select("data_gateway.id as gateway_id")
  scope :get_content_ids, joins("INNER JOIN data_gateway_conference ON data_gateway_conference.gateway_id = aggregate_custom.removable_id AND aggregate_custom.removable_type = 'DataGateway'").select("data_gateway_conference.content_id")
  scope :get_entryway_ids, joins("INNER JOIN data_entryway ON data_entryway.gateway_id = aggregate_custom.removable_id AND aggregate_custom.removable_type = 'DataGateway'").select("data_entryway.id as entryway_id")
end

# == Schema Information
#
# Table name: aggregate_custom
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  removable_id    :integer
#  removable_type  :string(255)
#  remove_children :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_aggregate_custom_on_removable_id                     (removable_id)
#  index_aggregate_custom_on_removable_id_and_removable_type  (removable_id,removable_type)
#  index_aggregate_custom_on_removable_type                   (removable_type)
#  index_aggregate_custom_on_user_id                          (user_id)
#

