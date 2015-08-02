class ReachoutTabMappingRule < ActiveRecord::Base
  attr_accessible :carrier_id, :carrier_title, :entryway_id, :entryway_provider
  has_many :reachout_tab_listener_minutes_by_gateways, foreign_key: :did_title
end
