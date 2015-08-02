class DataGateway < ActiveRecord::Base
  include Listener
  # SHARED METHODS
  include ::SharedMethods
  
  has_attached_file :logo, {
    :styles => {
      :thumb => ["80x80#", :png],      
      :large => ["300x300>", :png],
      :xhdpi => ["96x96", :png],
      :hdpi => ["72x72", :png],
      :mdpi => ["48x48", :png],
      :ldpi => ["36x36", :png],
      :background => ["320x250", :png]
    },
    :convert_options => {
      :thumb => "-gravity Center -crop 80x80+0+0",
      :background => "-filter Lanczos -distort Resize 320x"
    },
    :default_url => "/assets/default_:style_radio.png"
  }

  include PublicActivity::Model
  
  attr_accessor :gmaps, :custom_entryways, "data_groups"
  attr_accessible :title, :country_id, :language_id, :broadcast_id, :rca_id, :rca_monitor_id, :is_deleted,
    :ivr_welcome_prompt_id, :ivr_extension_ask_prompt_id, :ivr_extension_invalid_prompt_id, :data_contents_attributes,
    :ivr_welcome_enabled, :ivr_extension_invalid_enabled, :data_entryways_attributes, :data_entryway_ids, :data_entryway_did_e164s,
    :data_contents_attributes, :data_gateway_conferences_attributes, :reachout_tab_campaigns_attributes, :flag_broadcaster,
    :website, :data_entryway_id, :logo, :data_group_broadcast, :data_group_rca, :player_autoplay, :player_zeno_logo, :metadata, :widget_is_set_up
  validates :title, presence: true
  validates_columns :empty_extension_rule
  validates :website, :format => {:with => /\A(https?:\/\/)?[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]{2,6}(\/.*)?\Z/, :message => 'Incorrect Format!'}, :allow_blank => true
  validates_attachment :logo, content_type: { content_type: ["image/jpg", "image/jpeg", "image/gif", "image/png"], :message => 'Logo is in invalid format. Allowed formats are .jpg, .jpeg, .gif and .png' }

  after_save :update_entryways, :if => lambda {|gw| gw.is_deleted_changed? and gw.is_deleted.present? }

  belongs_to :data_group_broadcast, foreign_key: :broadcast_id
  belongs_to :data_group_rca, foreign_key: :rca_id
  belongs_to :data_group_rca_monitor, class_name: 'DataGroupRca', foreign_key: :rca_monitor_id
  belongs_to :data_group_country, foreign_key: :country_id
  belongs_to :data_group_language, foreign_key: :language_id
  has_many :reachout_tab_campaigns, foreign_key: :gateway_id
  accepts_nested_attributes_for :reachout_tab_campaigns
  

  belongs_to :country, class_name: "DataGroupCountry", foreign_key: :country_id
  belongs_to :language, class_name: "DataGroupLanguage", foreign_key: :language_id
  belongs_to :broadcaster_group, class_name: "DataGroupBroadcast", foreign_key: :broadcast_id
  belongs_to :rca_group, class_name: "DataGroupRca", foreign_key: :rca_id
  
  has_many :prompts, class_name: "DataGatewayPrompt", foreign_key: :gateway_id
  has_many :conferences, class_name: "DataGatewayConference", foreign_key: :gateway_id
  has_many :data_gateway_notes, foreign_key: :gateway_id
  has_many :data_gateway_conferences, foreign_key: :gateway_id
  accepts_nested_attributes_for :data_gateway_conferences
  has_many :data_contents, through: :data_gateway_conferences
  has_many :data_listener_at_gateways, foreign_key: :context_at_id
  # has_many :summary_sessions_by_gateways, foreign_key: :gateway_id
  # has_many :summary_listeners_by_gateways, foreign_key: :gateway_id
  has_many :data_gateway_prompts, foreign_key: :gateway_id

  belongs_to :welcome_prompt, class_name: "DataGatewayPrompt", foreign_key: :ivr_welcome_prompt_id
  belongs_to :ask_prompt, class_name: "DataGatewayPrompt", foreign_key: :ivr_extension_ask_prompt_id
  belongs_to :invalid_prompt, class_name: "DataGatewayPrompt", foreign_key: :ivr_extension_invalid_prompt_id

  has_many :reports, class_name: "ReportTotalMinutesByHour", foreign_key: :gateway_id
  has_many :report_minutes, class_name: "ReportSummaryListen", foreign_key: :gateway_id
  has_many :data_entryways, foreign_key: :gateway_id
  has_many :log_calls, foreign_key: :gateway_id

  has_many :now_sessions, foreign_key: :call_gateway_id

  # FOR NEW DB SCHEMA
  has_many :summary_listen, foreign_key: :gateway_id

  belongs_to :main_did, class_name: "DataEntryway", foreign_key: :data_entryway_id

  has_many :data_carrier_rules


  default_scope where(:is_deleted => false)

  scope :with_rca, lambda {|user| where("rca_id IN ('#{user.data_group_rca_ids.last rescue 0}') OR rca_monitor_id IN ('#{user.data_group_rca_ids.last rescue 0}')")}
  scope :with_broadcast, lambda {|user| where(:broadcast_id => user.data_group_broadcast_ids)}
  scope :with_thirdparty, lambda {|user| self.joins(:data_entryways).where("data_entryway.3rdparty_id" => user.data_group_3rdparty_ids)}
  scope :with_country, lambda {|id| where(:country_id => id) }


  accepts_nested_attributes_for :data_entryways, :allow_destroy => true, :reject_if => proc {|record| record["title"].blank? || record["did_e164"].blank?}, :allow_destroy => true
  accepts_nested_attributes_for :data_contents, :allow_destroy => true

  #==========================================================================
  # Input:
  # + name:, format:
  # Output:
  # + name:, format:
  # Description:?
  # Notes:
  #==========================================================================
  def self.list_with_status_on_group(role, group_id)
    if role.to_i == MyRadioHelper::Role::VALUES['rca']
      status = "CASE data_gateway.rca_id WHEN #{group_id} THEN true ELSE false END"
      #condition = ["data_gateway.rca_id = ? or data_gateway.rca_id is null", group_id]
    elsif role.to_i == MyRadioHelper::Role::VALUES['broadcaster']
      status = "CASE data_gateway.broadcast_id WHEN #{group_id} THEN true ELSE false END"
      #condition = ["data_gateway.broadcast_id = ? or data_gateway.broadcast_id is null", group_id]
    end

    if group_id.present? and status
      data = self.select("data_gateway.id, data_gateway.title, #{status} AS status")
    else
      data = []
    end
    data
  end

  def self.get_for_rca_broadcast(user)
    if user.is_rca?
      result = self.with_rca(user)
    elsif user.is_broadcaster?
      result = self.with_broadcast(user)
    end
    result
  end

  def entryway_ids
    data_entryways.collect(&:id).join(",")
  end

  def entryway_names
    data_entryways.collect(&:did_e164).join(",")
  end

  def self.get_dids(id)
    ob = self.find_by_id(id)
    ob.nil? ? "" : ob.data_entryways.map(&:did_e164).join(", ")
  end

  def self.get_aggregate_tracking_stations(user, from_date=Date.today, to_date=Date.today, hour = 1 )
    result = self.joins("
      LEFT JOIN log_call ON `data_gateway`.`id` = `log_call`.`gateway_id` ")
    .select("sum(log_call.seconds/60) as total_minutes")
    if !user.is_marketer?
      result = result.where("data_gateway.rca_id in (?)", user.data_group_rca_ids)
    end
    result.where("hour(date_start) = ? AND date_start BETWEEN ? and ?", hour, from_date, to_date).order("date_start ASC")
  end

  # dids: list of entryway ids.
  def self.get_selected_tracking_stations(user, gateway_ids = [],from_date=Date.today, to_date=Date.today, hour = 1 )
    inner_sql = LogCall.where("data_gateway.id = log_call.gateway_id")
    .where("hour(log_call.date_start) = ? AND date_start BETWEEN ? and ? ", hour, from_date, to_date)
    .select("sum(seconds / 60) as total_minutes").to_sql
    result = self.select("data_gateway.title as title, (#{inner_sql}) as total_minutes")
    result = result.where("data_gateway.id in (?)", gateway_ids)
    if !user.is_marketer?
      result = result.where("data_gateway.rca_id in (?)", user.data_group_rca_ids)
    end
    result.order("title ASC")
  end

  # For slider
  def self.top_stations(user ,options = {})
    raise "Dan: This query is heavy. Prevent calling it"
    stations = self.joins(:summary_listen)
    stations = stations.where("date(summary_listen.date) >= ?", options[:day].to_i.send("days").ago.to_date.to_time)
    stations = stations.group("data_gateway.id")
    stations = stations.select("data_gateway.*, sum(summary_listen.seconds) as minutes")
    stations = stations.order("sum(summary_listen.seconds) DESC")

    if options[:limit]
      stations = stations.limit(options[:limit])
    end
    stations
  end

  #==========================================================================
  # Method: get
  # Parameters:
  # + query:, format: title search or did search
  # + country_id:, format:
  # + rca_id:, format:
  # Responses:
  #   - stations
  # Description:
  #   - filter search result for slider search
  # Notes:
  #==========================================================================
  def self.filter(query, country_id, rca_id, user, page)
    select = "data_gateway.id, data_gateway.title, data_gateway.logo_file_name, data_gateway.logo_content_type, data_gateway.logo_file_size, data_gateway.logo_updated_at, data_gateway.rca_id, data_gateway.rca_monitor_id"
    if query.present?
      where = ""
      if user.is_rca?
        where = " AND data_gateway.rca_id = #{user.sys_user_resource_rcas.first[:rca_id]}"
      elsif user.is_broadcaster?
        where = " AND data_gateway.broadcast_id = #{user.sys_user_resource_broadcast.first[:broadcast_id]}"
      end
      # stations = self.joins(:data_entryways).where("data_entryway.did_e164 like ? AND data_gateway.is_deleted='0' #{where}","%#{query}%").select(select + ", data_entryway.title as de_title").group("data_gateway.id")
      stations = self.joins("LEFT JOIN data_entryway as data_entryway on data_entryway.gateway_id= data_gateway.id").where("data_gateway.title like '%#{query}%' OR data_entryway.title LIKE '%#{query}%' OR data_entryway.did_e164 like '%#{query}%' AND data_gateway.is_deleted='0' #{where}").select(select).group("data_gateway.id")
      if country_id && country_id > 0
        stations = stations.where(:country_id => country_id)
      end
      if rca_id && rca_id > 0
        stations = stations.where(:rca_id => rca_id)
      end
    else
      stations = self.select(select)
      if country_id && country_id > 0
        stations = stations.where(:country_id => country_id)
      end
      if rca_id && rca_id > 0
        stations = stations.where(:rca_id => rca_id)
      end
    end
    count = (stations.length.to_f / 16).ceil
    [count, stations.limit(16).offset((page-1)*16)]
  end

  def today_minutes
    reports.where(report_date: Date.today).collect(&:total_minutes).sum
  end

  private
  def update_entryways
    self.data_entryways.update_all(gateway_id: nil, country_id: nil, '3rdparty_id' => nil)
  end

end

# == Schema Information
#
# Table name: data_gateway
#
#  id                                :integer          not null, primary key
#  title                             :string(200)
#  country_id                        :integer
#  language_id                       :integer
#  broadcast_id                      :integer?
#  rca_id                            :integer
#  is_deleted                        :boolean          default(FALSE)
#  empty_extension_rule              :string(10)       default("PLAY_FIRST")
#  empty_extension_threshold_count   :integer          default(2)
#  invalid_extension_rule            :string(10)       default("PLAY_FIRST")
#  invalid_extension_threshold_count :integer          default(3)
#  ivr_welcome_enabled               :boolean          default(TRUE)
#  ivr_welcome_prompt_id             :integer
#  ivr_extension_ask_prompt_id       :integer
#  ivr_extension_invalid_enabled     :boolean          default(TRUE)
#  ivr_extension_invalid_prompt_id   :integer
#  flag_disable_advertise            :boolean          default(FALSE)
#  flag_disable_advertise_forward    :boolean          default(FALSE)
#
# Indexes
#
#  fk_data_gateway_1_idx  (country_id)
#  fk_data_gateway_2_idx  (language_id)
#  fk_data_gateway_3_idx  (broadcast_id)
#  fk_data_gateway_4_idx  (rca_id)
#  fk_data_gateway_5      (ivr_welcome_prompt_id)
#  fk_data_gateway_6      (ivr_extension_ask_prompt_id)
#  fk_data_gateway_7      (ivr_extension_invalid_prompt_id)
#

