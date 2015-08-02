class DataCarrierRule < ActiveRecord::Base
  attr_accessible :gateway_id, :entryway_provider_id, :new_entryway_provider_id, :parent_carrier_id, :gateway_prompt_id, :hangup_after_play, :is_enabled
  belongs_to :data_parent_carrier, foreign_key: :parent_carrier_id
  belongs_to :data_gateway, foreign_key: :gateway_id
  belongs_to :data_entryway_provider, foreign_key: :entryway_provider_id
  belongs_to :new_data_entryway_provider, class_name: 'DataEntrywayProvider', foreign_key: :new_entryway_provider_id
  belongs_to :data_gateway_prompt, foreign_key: :gateway_prompt_id

  validates :gateway_id, :entryway_provider_id, :parent_carrier_id, :gateway_prompt_id, presence: true

end
