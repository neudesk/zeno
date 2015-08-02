class DataGroupBroadcast < ActiveRecord::Base
  attr_accessible :title
  has_many :data_gateways, foreign_key: :broadcast_id
  has_many :gateways, class_name: "DataGateway", foreign_key: :broadcast_id
  has_many :data_contents, foreign_key: :broadcast_id
  has_many :sys_user_resource_broadcasts, foreign_key: :broadcast_id
  has_many :sys_users, through: :sys_user_resource_broadcasts, source: :user
  # has_many :summary_sessions_by_gateways, foreign_key: :broadcast_id

  # SHARED METHODS
  include ::SharedMethods
  attr_accessible :title, :reachout_tab_is_active, :upload_list_is_active
  accepts_nested_attributes_for :data_gateways
  validates_presence_of :title

  def refresh_gateways(selected_ids)
    # self.gateways.update_all(broadcast_id: nil)
    return true unless selected_ids.present?
    selected_ids.each do |selected_id|
      gateway = DataGateway.find_by_id(selected_id)
      old_broadcast_id = gateway.broadcast_id.present? ? gateway.broadcast_id : nil
      gateway.update_attributes(broadcast_id: id)
      new_broadcast_id = gateway.broadcast_id.present? ? gateway.broadcast_id : nil
      parameters = {:old_broadcast_id => old_broadcast_id,
                    :new_broadcast_id => new_broadcast_id,
                    :object_updated => 'DataGroupBroadcast',
                    :gateway_title => gateway.title}
      gateway.create_activity :key => 'data_gateway.grouping', user_title: user_title, :owner => user, :trackable_title => "#{user.username} (#{user.email})", :parameters => parameters
    end
  end
end

# == Schema Information
#
# Table name: data_group_broadcast
#
#  id         :integer          not null, primary key
#  title      :string(200)
#  is_deleted :boolean          default(FALSE)
#

