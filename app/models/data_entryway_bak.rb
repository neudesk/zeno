class DataEntryway < ActiveRecord::Base
  include Listener
  # SHARED METHODS
  include ::SharedMethods

  attr_accessor :gmaps
  attr_accessible :title, :did_e164, :gateway_id, :country_id, :"3rdparty_id", :entryway_provider,
                  :data_entryway_provider_attributes

  validates :title, :did_e164, :presence => true
  belongs_to :data_group3rdparty, foreign_key: "3rdparty_id"
  belongs_to :data_group_country, foreign_key: :country_id
  belongs_to :data_gateway, foreign_key: :gateway_id
  belongs_to :data_entryway_provider, foreign_key: :entryway_provider
  has_many :summary_listeners_by_entryways, foreign_key: :entryway_id
  has_many :summary_sessions_by_entryways, foreign_key: :entryway_id
  has_many :data_listener_at_entryways, foreign_key: :entryway_id
  has_many :log_calls, foreign_key: :entryway_id

  has_many :now_sessions, foreign_key: :call_entryway_id

  # FOR NEW DB SCHEMA
  has_many :summary_listen, foreign_key: :entryway_id

  scope :with_3rdparty, lambda {|user| where("3rdparty_id" => user.data_group_3rdparty_ids)}
  scope :with_rca, lambda {|user| joins(:data_gateway).where("data_gateway.rca_id in (?)", user.data_group_rca_ids)}
  scope :with_country, lambda {|id| where(:country_id => id) }

  accepts_nested_attributes_for :data_entryway_provider, :allow_destroy => true , :reject_if => proc {|record| record["title"].blank?}

  def self.list_with_status_on_group(group_id)
    if group_id.present?
      status = "CASE data_entryway.3rdparty_id WHEN #{group_id} THEN true ELSE false END"
      condition = ["data_entryway.3rdparty_id = ? or data_entryway.3rdparty_id is null", group_id]
      data = self.where(condition).select("data_entryway.id, data_entryway.title, #{status} AS status")
    else
      data = []
    end
    data
  end

  def self.get_for_3rd_marketer(user)
    if user.is_marketer?
      result = self
    elsif user.is_thirdparty?
      result = self.with_3rdparty(user)
    end
    result
  end

  def self.get_aggregate_tracking_did(user, from_date=Date.today, to_date=Date.today, hour = 1 )
    result = self.joins("
      LEFT JOIN log_call ON `data_entryway`.`id` = `log_call`.`entryway_id`
      INNER JOIN `data_gateway` ON `data_gateway`.`id` = `data_entryway`.`gateway_id`")
    .select("sum(log_call.seconds/60) as total_minutes")

    if !user.is_marketer?
      result = result.where("data_gateway.rca_id in (?)", user.data_group_rca_ids)
    end
    result.where("hour(log_call.date_start) = ? AND date_start BETWEEN ? and ?", hour, from_date, to_date).order("date_start ASC")
  end

  # dids: list of entryway ids.
  def self.get_selected_tracking_did(user, dids = [],from_date=Date.today, to_date=Date.today, hour = 1 )

    inner_sql = LogCall.where("data_entryway.id = log_call.entryway_id").where("hour(date_start) = ? AND date_start BETWEEN ? and ? ", hour, from_date, to_date).select("sum(seconds / 60) as total_minutes").to_sql

    result = self.joins(:data_gateway)
    .select("data_entryway.did_e164 as did, (#{inner_sql}) as total_minutes")


    result = result.where("data_entryway.id in (?)", dids)

    if !user.is_marketer?
      result = result.where("data_gateway.rca_id in (?)", user.data_group_rca_ids)
    end
    result.order("did ASC")


  end

end

# == Schema Information
#
# Table name: data_entryway
#
#  id                             :integer          not null, primary key
#  title                          :string(200)
#  did_e164                       :string(32)
#  gateway_id                     :integer
#  country_id                     :integer
#  3rdparty_id                    :integer
#  entryway_provider              :integer
#  is_deleted                     :boolean          default(FALSE)
#  is_default                     :boolean          default(FALSE)
#  flag_disable_advertise         :boolean          default(FALSE)
#  flag_disable_advertise_forward :boolean          default(FALSE)
#
# Indexes
#
#  DID                      (did_e164)
#  fk_data_entryway_1_idx   (entryway_provider)
#  fk_data_entryway_1_idx1  (gateway_id)
#  fk_data_entryway_1_idx2  (3rdparty_id)
#  fk_data_entryway_1_idx3  (country_id)
#  gateway                  (gateway_id)
#  title                    (title)
#

