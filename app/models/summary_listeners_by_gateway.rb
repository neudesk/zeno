class SummaryListenersByGateway < ActiveRecord::Base
  attr_accessible :gateway_id, :date, :frequency_listen_dialy, :frequency_listen_weekly,
                  :frequency_unknown, :frequency_0_to_5_minutes_per_day,
                  :frequency_5_to_20_minutes_per_day, :frequency_20_to_60_minutes_per_day,
                  :frequency_more_60_minutes_per_day, :active_by_new, :active_by_return
  belongs_to :data_gateway, foreign_key: :gateway_id

  def self.listeners_count(user, number = 7, gateway_id = nil, entryway_id = nil)
    result = []
    where_cl = ["date >= '#{number.to_i.send("days").ago}'"]
    if user.is_thirdparty?
      if entryway_id.nil?
        
        if gateway_id && !ids.blank?
          ids = DataEntryway.find_all_by_gateway_id(gateway_id).map(&:id)
          where_cl << "entryway_id IN (#{ids.join(",")})" 
        end

        
        if gateway_id.nil? && !ids.blank?
          ids = DataEntryway.with_3rdparty(user).map(&:id)
          where_cl << "entryway_id IN (#{ids.join(",")})" 
        end
        
      else
        where_cl << "entryway_id = #{entryway_id.to_i}"
      end
      relations = SummaryListenersByEntryway.where(where_cl.join(" AND "))
    else
      if gateway_id
        where_cl << "gateway_id = #{gateway_id}"
      else
        if !user.is_marketer? && !ids.blank?
          ids = DataGateway.get_for_rca_broadcast(user).map(&:id)
          where_cl << "gateway_id IN ( #{ids.join(",")} )" 
        end
      end
      relations = self.where(where_cl.join(" AND "))
    end
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

  def self.top_listeners(options = {})
    sort = "summary_sessions_by_gateway.date desc"
    where_str = ""
    unless options[:week].blank?
      start_date = Date.commercial(DateTime.now.year, options[:week].to_i).beginning_of_week
      end_date = Date.commercial(DateTime.now.year, options[:week].to_i).end_of_week
      where_str = "WHERE date(summary_sessions_by_gateway.date) BETWEEN '#{start_date}' AND '#{end_date}'"
    end

    sort = "#{options[:sort]} #{options[:direction]}" unless options[:sort].blank?
    unless options[:gateway_id].blank?
      if where_str.blank?
        where_str = "WHERE `summary_sessions_by_gateway`.`gateway_id` = '#{options[:gateway_id]}'"
      else
        where_str << "ANd `summary_sessions_by_gateway`.`gateway_id` = '#{options[:gateway_id]}'"
      end
    end

    sql = %Q{
      SELECT distinct summary_sessions_by_gateway.date as listenerDate,
      summary_sessions_by_gateway.seconds as minute, summary_sessions_by_gateway.gateway_id,
      '' as listener_name, '' as provider_name
      FROM summary_sessions_by_gateway
      INNER JOIN data_gateway ON `data_gateway`.`id` = `summary_sessions_by_gateway`.`gateway_id`
      #{where_str}
      GROUP BY date(summary_sessions_by_gateway.date), summary_sessions_by_gateway.gateway_id
      ORDER BY #{sort}
    }

    sql = %Q{
      SELECT distinct summary_sessions_by_gateway.rca_id as rca, summary_sessions_by_gateway.date as listenerDate,
       sum(summary_sessions_by_gateway.seconds)/60 as minute, summary_sessions_by_gateway.gateway_id,
       summary_sessions_by_gateway.id as listener_id, data_listener.title as listener_name,
       data_listener_ani_carrier.title as provider_name
       FROM summary_sessions_by_gateway
       INNER JOIN data_gateway ON `data_gateway`.`id` = `summary_sessions_by_gateway`.`gateway_id`
       AND `data_gateway`.`rca_id` = `summary_sessions_by_gateway`.`rca_id`
       INNER JOIN data_listener_at_gateway ON `data_listener_at_gateway`.`id` = `summary_sessions_by_gateway`.`gateway_id`
       INNER JOIN data_listener ON `data_listener_at_gateway`.`listener_id` = `data_listener`.`id`
       INNER JOIN data_listener_ani ON `data_listener_ani`.`listener_id` = `data_listener`.`id`
       INNER JOIN data_listener_ani_carrier ON `data_listener_ani`.`carrier_id` = `data_listener_ani_carrier`.`id`
       #{where_str}
       GROUP BY date(summary_sessions_by_gateway.date), summary_sessions_by_gateway.gateway_id
       ORDER BY summary_sessions_by_gateway.date desc
    }
    SummaryListenersByGateway.find_by_sql(sql)
  end
end

# == Schema Information
#
# Table name: summary_listeners_by_gateway
#
#  id                                 :integer          not null, primary key
#  date                               :date
#  gateway_id                         :integer
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
#  fk_summary_listeners_by_gateway_1_idx  (gateway_id)
#

