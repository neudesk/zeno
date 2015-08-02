class SummarySessionsByContent < ActiveRecord::Base
  attr_accessible :date, :hour, :content_id, :country_id, :language_id, :genre_id,
                  :broadcast_id, :sessions, :sessions_acd_10sec, :sessions_acd_1min,
                  :sessions_acd_5min, :sessions_acd_20min, :sessions_acd_1hr,
                  :sessions_acd_2hr, :sessions_acd_6hr, :sessions_acd_more6hr, :seconds
  belongs_to :data_group_broadcast, foreign_key: :broadcast_id
  belongs_to :data_content, foreign_key: :content_id
  belongs_to :data_group_country, foreign_key: :country_id
  belongs_to :data_group_language, foreign_key: :language_id
  belongs_to :data_group_genre, foreign_key: :genre_id

  def self.get_report
    self.group("summary_sessions_by_content.content_id, date, summary_sessions_by_content.country_id")
        .select("date, summary_sessions_by_content.country_id, summary_sessions_by_content.content_id, sum(seconds) as total_second")
        .order("date ASC")
  end

  # for gateway
  # options = { broken_down_by: :day/:hour, from_date: xyz, end_date: xyz }
  def self.get_report_for_gateway(gateway_id, options = {broken_down_by: :day}, removed_content_ids=[])
    result = get_report.joins(:data_content => :data_gateway_conferences).where("data_gateway_conference.gateway_id = ?", gateway_id)
    result = result.group("hour").select("hour") if options[:broken_down_by] == :hour
    result = result.where("date >= ?", options[:from_date]) if options[:from_date].present?
    result = result.where("date >= ?", options[:end_date]) if options[:end_date].present?
    unless removed_content_ids.empty?
      result = result.where("summary_sessions_by_content.content_id NOT IN (?)", removed_content_ids)
    end
    result
  end

  def self.get_average_time_per_user 
    sum_hour_select_to_7_weeks = []
    8.times do |t|
      start_date = t == 0 ? Date.today.beginning_of_week : t.weeks.ago.beginning_of_week
      end_date = t == 0 ? Date.today.beginning_of_week : t.weeks.ago.end_of_week
      sum_hour_select_to_7_weeks << <<-EOF
        (SELECT sum(hour)
        FROM summary_sessions_by_content 
        INNER JOIN data_group_country as sub_c ON sub_c.id = summary_sessions_by_content.country_id
        INNER JOIN data_content as sub_dc ON sub_dc.id = summary_sessions_by_content.content_id 
        WHERE (date >= '#{start_date}' AND date <= '#{end_date}' AND sub_dc.id = dc.id AND c.id = sub_c.id) 
        ORDER BY radio_name) as week_#{t}
      EOF
    end

    self.joins("INNER JOIN data_group_country as c ON c.id = summary_sessions_by_content.country_id
                INNER JOIN data_content as dc ON dc.id = summary_sessions_by_content.content_id")
              .select("dc.title as radio_name, c.title as country_name, #{sum_hour_select_to_7_weeks.join(" , ")}")
              .group("dc.title, c.title")
              .order("radio_name")
  end

  def self.minutes_count(user ,number = 7, content_id = nil)
    result = []
    where_cl = (number == 0) ? [] : ["date >= '#{number.to_i.send("days").ago}'"]
    if content_id
      where_cl << "content_id = #{content_id}"
    else
      content_ids = DataContent.get_channels(user).last
      where_cl << "content_id IN (#{content_ids.join(",")})" unless content_ids.blank?
    end
    relations = self.where(where_cl.join(" AND "))
    result << count_for_wday(relations, 0, "Sunday")
    result << count_for_wday(relations, 1, "Monday")
    result << count_for_wday(relations, 2, "Tuesday")
    result << count_for_wday(relations, 3, "Wednesday")
    result << count_for_wday(relations, 4, "Thursday")
    result << count_for_wday(relations, 5, "Friday")
    result << count_for_wday(relations, 6, "Saturday")
    result
  end

  def self.count_for_wday(relations, wday, day)
    seconds = relations.select{|x| x.date.wday == wday}.map{|y| y.seconds.to_i}.sum
    [day, (seconds.to_f/60).round(2)]
  end
end

# == Schema Information
#
# Table name: summary_sessions_by_content
#
#  id                   :integer          not null, primary key
#  date                 :date
#  hour                 :integer
#  content_id           :integer
#  country_id           :integer
#  language_id          :integer
#  genre_id             :integer
#  broadcast_id         :integer
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
#  date                                              (date)
#  date-hr                                           (date,hour)
#  fk_summary_minutes_listen_sessions_content_1_idx  (content_id)
#  fk_summary_minutes_listen_sessions_content_2_idx  (country_id)
#  fk_summary_minutes_listen_sessions_content_3_idx  (language_id)
#  fk_summary_minutes_listen_sessions_content_4_idx  (genre_id)
#  fk_summary_minutes_listen_sessions_content_5_idx  (broadcast_id)
#

