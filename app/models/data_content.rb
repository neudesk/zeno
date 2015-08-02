class DataContent < ActiveRecord::Base
  attr_accessible :title, :broadcast_id, :country_id, :language_id, :genre_id, :media_type, :media_url, :data_group_language_attributes, :is_deleted, :backup_media_url, :onair_title

  attr_accessor :extension

  # SHARED METHODS
  include ::SharedMethods
  include PublicActivity::Model

  before_create :set_default_media_type

  belongs_to :data_group_broadcast, foreign_key: :broadcast_id
  belongs_to :data_group_country, foreign_key: :country_id
  belongs_to :data_group_language, foreign_key: :language_id
  belongs_to :data_group_genre, foreign_key: :genre_id

  belongs_to :genre, class_name: "DataGroupGenre", foreign_key: :genre_id
  belongs_to :broadcast, class_name: "DataGroupBroadcast", foreign_key: :broadcast_id
  belongs_to :country, class_name: "DataGroupCountry", foreign_key: :country_id
  belongs_to :language, class_name: "DataGroupLanguage", foreign_key: :language_id
  
  has_many :data_gateway_conferences, foreign_key: :content_id
  has_many :data_gateways, through: :data_gateway_conferences

  # FOR NEW DB SCHEMA
  has_many :summary_listen, foreign_key: :content_id
  has_many :data_content_off_air, foreign_key: :content_id

  accepts_nested_attributes_for :data_group_language, :allow_destroy => true
  accepts_nested_attributes_for :data_content_off_air, :allow_destroy => true
  validates :media_url, presence: true, uniqueness: true if :is_deleted == false
  #validates :title, :length => { :maximum => 30 }
  default_scope where(:is_deleted => false)
  
  def authenticateRadioJar
    result = HTTParty.get("#{RADIO_JAR_ENDPOINT}/api/Login/create", 
                            query: {data: '{"handler": "system", "password": "imasecret", "infinite": true}'})
    result['data']['token']
  end

  def updateRadioJar(is_enabled)
    token = authenticateRadioJar
    result = HTTParty.get("#{RADIO_JAR_ENDPOINT}/api/DataContent/update", 
                            query: {data: "{\"id\": #{self.id}, \"radioJarEnabled\": #{is_enabled}}", token: token})
  end

  def sendMediaUrlToRadioJar
    token = authenticateRadioJar
    result = HTTParty.get("#{RADIO_JAR_ENDPOINT}/api/DataContent/update",
                          query: {data: "{\"id\": #{self.id}, \"mediaUrl\": \"#{self.media_url}\"}", token: token})
  end

  def set_default_media_type
    self.media_type = "FFMPEG"
  end

  def active?
    status == :up
  end

  def old_title
  end
  
  def old_title=(title)    
  end

  def desktop?
    title.include?("WDG") || title.include?("ANDROID")
  end

  def self.get_channels(user, gateway_id = nil, field = nil)
    if gateway_id.nil?
      if user.is_marketer?
        if field == "title"
          arrs = self.select("title,id").order("title")
        else
          arrs = self.select(field).order("title")
        end
        
      elsif user.is_thirdparty?
        entryway_ids = DataEntryway.with_3rdparty(user)
        gateway_ids = entryway_ids.map{|x| x.gateway_id}
        wheres = gateway_ids.blank? ? "" : "data_gateway.id IN (#{gateway_ids.join(",")})"
        arrs = DataGateway.where(wheres)
                          .joins([:data_gateway_conferences => :data_content])
                          .order("data_content.title")
                          .select("distinct data_content.id as id, data_content.title as title")
      else
        arrs = DataGateway.get_for_rca_broadcast(user)
                          .joins([:data_gateway_conferences => :data_content])
                          .order("data_content.title")
                          .select("distinct data_content.id as id, data_content.title as title")
      end
    else
      arrs = DataGateway.find(gateway_id).data_contents
#      arrs = DataGateway.joins([:data_gateway_conferences => :data_content])
#                        .where("data_gateway.id = #{gateway_id}").order("data_content.title")
#                        .select("distinct data_content.id as id, data_content.title as title")
    end

      return arrs = arrs.map{|x| x.id} if field == 'id'
      arrs
  end
  #==========================================================================
  # Method: get
  # Parameters:
  #  - stream_name: content title
  # Responses:
  #  - data content
  # Description: 
  #  - Search the first content which has title matched with stream_name
  # Notes: 
  #==========================================================================
  def self.search_by_stream_name(stream_name)
    
    data_contents = self.where("data_content.title like ? AND is_deleted='0'", "%#{stream_name}%").order("trim(title)")
    return data_contents

  end

end

# == Schema Information
#
# Table name: data_content
#
#  id                                :integer          not null, primary key
#  title                             :string(200)
#  broadcast_id                      :integer
#  country_id                        :integer
#  language_id                       :integer
#  genre_id                          :integer
#  media_type                        :string(32)
#  media_url                         :string(255)
#  is_deleted                        :boolean          default(FALSE)
#  flag_disable_advertise_forward    :boolean          default(FALSE)
#  flag_disable_advertise            :boolean          default(FALSE)
#  advertise_timmer_interval_minutes :integer          default(15)
#
# Indexes
#
#  fk_data_content_1_idx   (broadcast_id)
#  fk_data_content_1_idx1  (country_id)
#  fk_data_content_1_idx2  (language_id)
#  gener_idx               (genre_id)
#

