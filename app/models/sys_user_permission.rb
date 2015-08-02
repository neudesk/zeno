class SysUserPermission < ActiveRecord::Base
  attr_accessible :title, :is_super_user, :can_manage_specific_3rdparty_resources,
                  :can_manage_specific_broadcast_resources,
                  :can_manage_specific_rca_resources,
                  :can_manage_all_zenoradio_data,
                  :can_manage_all_zenoradio_metadata,
                  :can_manage_all_zenoradio_users
  has_many :users, foreign_key: :permission_id

end
# == Schema Information
#
# Table name: sys_user_permission
#
#  id      :integer          not null, primary key
#  title                                :string(200)
#  can_login_at_noc                     :boolean          default(FALSE)
#  can_manage_all_entryways             :boolean          default(FALSE)
#  can_manage_all_gateways              :boolean          default(FALSE)
#  can_manage_all_contents              :boolean          default(FALSE)
#  can_manage_all_group_data            :boolean          default(FALSE)
#  can_manage_all_campaigns             :boolean          default(FALSE)
#  can_manage_all_sys_users             :boolean          default(FALSE)
#  can_manage_all_sys_servers           :boolean          default(FALSE)
#  can_write_3rdparty_resources         :boolean          default(FALSE)
#  can_write_advertise_agency_resources :boolean          default(FALSE)
#  can_write_broadcast_resources        :boolean          default(FALSE)
#  can_write_rca_resources              :boolean          default(FALSE)
#  can_read_3rdparty_resources          :boolean          default(FALSE)
#  can_read_advertise_agency_resources  :boolean          default(FALSE)
#  can_read_broadcast_resources         :boolean          default(FALSE)
#  can_read_rca_resources               :boolean          default(FALSE)
#

