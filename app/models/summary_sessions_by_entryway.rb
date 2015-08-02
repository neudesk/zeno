class SummarySessionsByEntryway < ActiveRecord::Base
  attr_accessible :date, :hour, :entryway_id, :entryway_provider_id, :country_id,
                  "3rdparty_id", :sessions, :sessions_acd_10sec, :sessions_acd_1min,
                  :sessions_acd_5min, :sessions_acd_20min, :sessions_acd_1hr,
                  :sessions_acd_2hr, :sessions_acd_6hr, :sessions_acd_more6hr, :seconds
  belongs_to :data_group3rdparty, foreign_key: "3rdparty_id"
  belongs_to :data_entryway, foreign_key: :entryway_id
  belongs_to :data_group_country, foreign_key: :country_id
  belongs_to :data_entryway_provider, foreign_key: :entryway_provider_id

  def self.get_report
    self.joins(:data_entryway).group("data_entryway.did_e164").select("data_entryway.did_e164 as title")
        .group("#{self.table_name}.entryway_id, date, #{self.table_name}.country_id")
        .select("date, #{self.table_name}.country_id,#{self.table_name}.entryway_id as obj_id, sum(seconds) as total_second")
        .order("date ASC")
  end

  # for gateway
  # options = { broken_down_by: :day/:hour, from_date: xyz, end_date: xyz }
  def self.get_report_for_gateway(gateway_id, options = {broken_down_by: :day}, removed_entryway_ids=[])
    result = get_report.joins(:data_entryway).where(data_entryway: {gateway_id:  gateway_id})
    result = result.group("hour").select("hour") if options[:broken_down_by] == :hour
    result = result.where("date > ?", options[:from_date].to_date) if options[:from_date].present?
    result = result.where("date > ?", options[:end_date].to_date) if options[:end_date].present?
    unless removed_entryway_ids.empty?
      result = result.where("#{self.table_name}.entryway_id NOT IN (?)", removed_entryway_ids)
    end
    result
  end

  # for gateway
  # options = { broken_down_by: :day/:hour, from_date: xyz, end_date: xyz }
  def self.get_report_by_entryway_id(entryway_id, options = {broken_down_by: :day})
    result = get_report.joins(:data_entryway).group("data_entryway.gateway_id").select("data_entryway.gateway_id")
    result = result.group("hour").select("hour") if options[:broken_down_by] == :hour
    result = result.where("date > ?", options[:from_date].to_date) if options[:from_date].present?
    result = result.where("date > ?", options[:end_date].to_date) if options[:end_date].present?
    result.where("#{self.table_name}.entryway_id = ?", entryway_id)
  end

  def self.get_aggregate(options = {broken_down_by: :day}, from_date=1.week.ago.to_date)
    result = self.joins(:data_entryway => [:data_group_country, :data_gateway]).group("date").select("date as called_date, sum(seconds/60) as total_minutes")

    result = result.group("hour").select("hour as called_hour") if options[:broken_down_by] == :hour

    result.where("date > ?", from_date.to_date).order("date ASC")
  end
end

# == Schema Information
#
# Table name: summary_sessions_by_entryway
#
#  id                   :integer          not null, primary key
#  date                 :date
#  hour                 :integer
#  entryway_id          :integer
#  entryway_provider_id :integer
#  country_id           :integer
#  3rdparty_id          :integer
#  sessions             :integer
#  sessions_acd_10sec   :integer
#  sessions_acd_1min    :integer
#  sessions_acd_5min    :integer
#  sessions_acd_20min   :integer
#  sessions_acd_1hr     :integer
#  sessions_acd_2hr     :integer
#  sessions_acd_6hr     :integer
#  sessions_acd_more6hr :integer
#  seconds              :integer
#
# Indexes
#
#  date                                   (date)
#  date-hr                                (date,hour)
#  fk_summary_sessions_by_entryway_1_idx  (entryway_id)
#  fk_summary_sessions_by_entryway_2_idx  (entryway_provider_id)
#  fk_summary_sessions_by_entryway_3_idx  (country_id)
#  fk_summary_sessions_by_entryway_4_idx  (3rdparty_id)
#

