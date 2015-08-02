class SysUserResourceAdvertiseAgency < ActiveRecord::Base
  # attr_accessible :title, :body
end

# == Schema Information
#
# Table name: sys_user_resource_advertise_agency
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  advertise_agency_id :integer
#
# Indexes
#
#  fk_sys_user_resource_advertise_agency_1_idx  (user_id)
#  fk_sys_user_resource_advertise_agency_2_idx  (advertise_agency_id)
#

