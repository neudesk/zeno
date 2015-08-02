class DataListener < ActiveRecord::Base
  attr_accessible :title, :area_code
  has_many :data_listener_anis, foreign_key: :listener_id
  has_many :data_listeners_ani_carries, :through => :data_listener_anis
  has_many :data_listener_at_entryways, foreign_key: :listener_id
  has_many :data_listener_at_gateways, foreign_key: :listener_id
  has_many :data_listener_at_contents, foreign_key: :listener_id
  has_many :log_call_answers, foreign_key: :listener_id
end

# == Schema Information
#
# Table name: data_listener
#
#  id                         :integer          not null, primary key
#  title                      :string(200)
#  flag_push_marketing_opt_in :boolean          default(FALSE)
#  area_code                  :string(255)
#

