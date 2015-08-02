class DataGatewayConference < ActiveRecord::Base

  default_scope order("CAST(extension AS SIGNED INTEGER)")

  include PublicActivity::Model

  
  belongs_to :data_gateway, foreign_key: :gateway_id
  belongs_to :data_content, foreign_key: :content_id
  belongs_to :content, class_name: "DataContent", foreign_key: :content_id
  belongs_to :gateway, class_name: "DataGateway", foreign_key: :gateway_id
  accepts_nested_attributes_for :data_content, :reject_if => proc {|record| record["media_url"].blank?}, :allow_destroy => true
  accepts_nested_attributes_for :content
  attr_accessible :gateway_id, :extension, :data_content_attributes, :content_id, :content_attributes
  scope :by_datagateway, lambda {|gateway_ids| where(:gateway_id => gateway_ids)}
  validates :extension, presence: true
  validates :extension, :length => { :maximum => 30 }
  validates :extension, exclusion: { in: %w(0),
    message: "Not Valid Extension." }
  validates_associated :content
  tracked owner: ->(controller, model) { controller && controller.current_user }, except: [:update, :destroy],
    params: { :gateway_id => :gateway_id, :content_id => :content_id, :channel_no => :extension, :media_url => proc {|controller,model| model.data_content.media_url } },
      trackable_title: proc {|controller, model| model.data_gateway.title },
      sec_trackable_title: :gateway_id,
      sec_trackable_type: 'DataGateway',
      user_title: proc {|controller, model| controller && "#{controller.current_user.title} (#{controller.current_user.email})" }
end

# == Schema Information
#
# Table name: data_gateway_conference
#
#  id         :integer          not null, primary key
#  gateway_id :integer
#  content_id :integer
#  extension  :string(16)
#
# Indexes
#
#  fk_data_gateway_content_1_idx  (gateway_id)
#  fk_data_gateway_content_2_idx  (content_id)
#

