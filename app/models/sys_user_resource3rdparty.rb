class SysUserResource3rdparty < ActiveRecord::Base
  self.table_name = :sys_user_resource_3rdparty
  attr_accessible "3rdparty_id", :user_id
  belongs_to :user
  belongs_to :data_group_3rdparty, foreign_key: "3rdparty_id"
  has_many :data_entryways, foreign_key: "3rdparty_id"
end

# == Schema Information
#
# Table name: sys_user_resource_3rdparty
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  3rdparty_id :integer
#
# Indexes
#
#  fk_sys_user_resource_3rdparty_1_idx  (user_id)
#  fk_sys_user_resource_3rdparty_2_idx  (3rdparty_id)
#

