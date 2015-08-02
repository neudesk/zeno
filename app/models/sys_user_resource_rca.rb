class SysUserResourceRca < ActiveRecord::Base
  attr_accessible :rca_id, :user_id
  belongs_to :user
  belongs_to :data_group_rca, foreign_key: :rca_id

  has_many :data_gateways, foreign_key: :rca_id
end

# == Schema Information
#
# Table name: sys_user_resource_rca
#
#  id      :integer          not null, primary key
#  user_id :integer
#  rca_id  :integer
#
# Indexes
#
#  fk_sys_user_resource_rca_1_idx   (user_id)
#  fk_sys_user_resource_rca_1_idx1  (rca_id)
#

