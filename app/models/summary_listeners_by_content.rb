class SummaryListenersByContent < ActiveRecord::Base
  attr_accessible :content_id, :date, :frequency_listen_dialy, :frequency_listen_weekly,
                  :frequency_unknown, :frequency_0_to_5_minutes_per_day,
                  :frequency_5_to_20_minutes_per_day, :frequency_20_to_60_minutes_per_day,
                  :frequency_more_60_minutes_per_day, :active_by_new, :active_by_return
  belongs_to :data_content, foreign_key: :content_id
  def self.listeners_count(user, number = 7, content_id = nil)
    result = []
    where_cl = ["date >= '#{number.to_i.send("days").ago}'"]
    if content_id
      where_cl << "content_id = #{content_id}"
    else
      content_ids = DataContent.get_channels(user).last
      where_cl << "content_id IN (#{content_ids.join(",")})"
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
    for_new = relations.select{|x| x.date.wday == wday}.map{|y| y.active_by_new.to_i}.sum
    for_return = relations.select{|x| x.date.wday == wday}.map{|y| y.active_by_return.to_i}.sum
    [day, for_return + for_new]
  end
end

# == Schema Information
#
# Table name: summary_listeners_by_content
#
#  id                                 :integer          not null, primary key
#  date                               :date
#  content_id                         :integer
#  status_not_active                  :integer
#  status_active                      :integer
#  status_lost                        :integer
#  active_by_new                      :integer
#  active_by_return                   :integer
#  frequency_listen_dialy             :integer
#  frequency_listen_weekly            :integer
#  frequency_unknown                  :integer
#  frequency_0_to_5_minutes_per_day   :integer
#  frequency_5_to_20_minutes_per_day  :integer
#  frequency_20_to_60_minutes_per_day :integer
#  frequency_more_60_minutes_per_day  :integer
#
# Indexes
#
#  date                                   (date)
#  fk_summary_listeners_by_content_1_idx  (content_id)
#

