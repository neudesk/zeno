class SummaryCall < ActiveRecord::Base
  attr_accessible :date, :entryway_id, :listener_ani_carrier_id, :count, :seconds

  belongs_to :data_entryway, foreign_key: :entryway_id
  belongs_to :data_listener_ani_carrier, foreign_key: :listener_ani_carrier_id



end

# Table: summary_call
# Columns:
# id  int(11) PK AI
# date  datetime 
# entryway_id bigint(20) UN 
# listener_ani_carrier_id bigint(20) UN 
# count mediumint(9) UN 
# seconds mediumint(9) UN 
