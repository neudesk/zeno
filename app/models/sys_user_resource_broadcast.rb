class SysUserResourceBroadcast < ActiveRecord::Base
  attr_accessible :broadcast_id, :user_id
  belongs_to :user
  belongs_to :data_group_broadcast, foreign_key: :broadcast_id

  has_many :data_gateways, foreign_key: :broadcast_id
  has_many :data_contents, foreign_key: :broadcast_id
end

# == Schema Information
#
# Table name: sys_user_resource_broadcast
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  broadcast_id :integer
#
# Indexes
#
#  fk_sys_user_resource_broadcast_1_idx  (user_id)
#  fk_sys_user_resource_broadcast_2_idx  (broadcast_id)
#

