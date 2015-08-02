class ReachoutTabListenerMinutesByGateway < ActiveRecord::Base
  attr_accessible :created_at, :listener_id, :gateway_id, :ani_e164, :did_e164, :minutes, :did_title, :carrier_title
  belongs_to :reachout_tab_mapping_rule, foreign_key: :entryway_provider
end
