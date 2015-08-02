class DataGroupRca < ActiveRecord::Base
  has_many :data_gateways, foreign_key: :rca_id
  has_many :sys_user_resource_rcas, foreign_key: :rca_id
  has_many :sys_users, through: :sys_user_resource_rcas, source: :user
  # has_many :summary_sessions_by_gateway, foreign_key: :rca_id
  attr_accessible :title, :reachout_tab_is_active, :upload_list_is_active

  has_many :gateways, class_name: "DataGateway", foreign_key: :rca_id
  has_many :gateway_monitors, class_name: "DataGateway", foreign_key: :rca_monitor_id

  # SHARED METHODS
  include ::SharedMethods
  include PublicActivity::Model

  accepts_nested_attributes_for :data_gateways
  validates_presence_of :title

  def refresh_gateways(selected_ids)
    # self.gateways.update_all(rca_id: nil)
    return true unless selected_ids.present?
    selected_ids.each do |selected_id|
      gateway = DataGateway.find_by_id(selected_id)
      old_rca_id = gateway.rca_id.present? ? gateway.rca_id : nil
      gateway.update_attributes(rca_id: id)
      new_rca_id = gateway.rca_id.present? ? gateway.rca_id : nil
      parameters = {:old_rca_id => old_rca_id,
                    :new_rca_id => new_rca_id,
                    :object_updated => 'DataGroupRca',
                    :gateway_title => gateway.title}
      gateway.create_activity :key => 'data_gateway.grouping', user_title: user_title, :owner => user, :trackable_title => "#{user.username} (#{user.email})", :parameters => parameters
    end
  end
end

# == Schema Information
#
# Table name: data_group_rca
#
#  id         :integer          not null, primary key
#  title      :string(200)
#  is_deleted :boolean          default(FALSE)
#

