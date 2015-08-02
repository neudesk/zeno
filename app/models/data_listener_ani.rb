class DataListenerAni < ActiveRecord::Base
  attr_accessible :title, :listener_id, :ani_e164, :carrier_id
  belongs_to :data_listener, foreign_key: :listener_id
  belongs_to :data_listener_ani_carrier, foreign_key: :carrier_id
  has_many :log_calls, foreign_key: :listener_ani_id
end

# == Schema Information
#
# Table name: data_listener_ani
#
#  id                 :integer          not null, primary key
#  listener_id        :integer
#  ani_e164           :string(64)
#  carrier_id         :integer
#  carrier_last_check :datetime
#
# Indexes
#
#  ani                         (ani_e164)
#  fk_data_listener_ani_1_idx  (listener_id)
#  fk_data_listener_ani_2_idx  (carrier_id)
#  lastcheck                   (carrier_last_check)
#

