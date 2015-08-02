class DataListenerAniCarrier < ActiveRecord::Base
  attr_accessible :title, :data247_id
  has_many :data_listener_anis, foreign_key: :carrier_id
  has_many :data_listeners, :through => :data_listener_anis

  def self.minutes_divided_clec
    s_total_time_current_day = self.joins(:data_listener_anis => :log_calls)
                                   .where("date(log_call.date_start) = ?", Date.today)
                                   .select("sum(log_call.seconds) as current_minute,
                                            count(log_call.listener_id),
                                            data_listener_ani.carrier_id")
                                   .group("data_listener_ani.carrier_id").to_sql

    s_total_time_current_week = self.joins(:data_listener_anis => :log_calls)
    .where("date(log_call.date_start) >= ? AND date(log_call.date_start) <= ?", Date.today.beginning_of_week, Date.today.end_of_week)
    .select("sum(log_call.seconds) as total_minute,
             count(log_call.listener_id),
             data_listener_ani.carrier_id")
    .group("data_listener_ani.carrier_id").to_sql

    sql = "SELECT dlac.title as provider, tcw.total_minute, tcd.current_minute
          FROM data_listener_ani_carrier as dlac
          LEFT JOIN data_listener_ani as dla ON dlac.id = dla.carrier_id
          LEFT JOIN (#{s_total_time_current_day}) as tcd ON tcd.carrier_id = dla.carrier_id
          LEFT JOIN (#{s_total_time_current_week}) as tcw ON tcw.carrier_id = dla.carrier_id
          GROUP BY dla.carrier_id
          ORDER BY provider"
    self.find_by_sql(sql)
  end

  def self.minutes_from_outbound_carrier
    s_total_time_current_day = self.joins(:data_listener_anis => :log_calls)
                                   .joins("LEFT JOIN data_gateway as dg ON dg.id = log_call.gateway_id
                                          INNER JOIN data_group_country as dgc ON dgc.id = dg.country_id AND dgc.id != 1")
                                   .where("date(log_call.date_start) = ?", Date.today)
                                   .select("sum(log_call.seconds) as current_minute, count(log_call.listener_id), data_listener_ani.carrier_id")
                                   .group("data_listener_ani.carrier_id").to_sql

    s_total_time_current_week = self.joins(:data_listener_anis => :log_calls)
                                    .joins("LEFT JOIN data_gateway as dg ON dg.id = log_call.gateway_id
                                            INNER JOIN data_group_country as dgc ON dgc.id = dg.country_id AND dgc.id != 1")
                                    .where("date(log_call.date_start) >= ? AND date(log_call.date_start) <= ?", Date.today.beginning_of_week, Date.today.end_of_week)
                                    .select("sum(log_call.seconds) as total_minute, count(log_call.listener_id), data_listener_ani.carrier_id")
                                    .group("data_listener_ani.carrier_id").to_sql

    sql = "SELECT dlac.title as provider, tcw.total_minute, tcd.current_minute FROM data_listener_ani_carrier as dlac
          LEFT JOIN data_listener_ani as dla ON dlac.id = dla.carrier_id
          LEFT JOIN (#{s_total_time_current_day}) as tcd ON tcd.carrier_id = dla.carrier_id
          LEFT JOIN (#{s_total_time_current_week}) as tcw ON tcw.carrier_id = dla.carrier_id
          GROUP BY dla.carrier_id
          ORDER BY provider"
    self.find_by_sql(sql)
  end
end

# == Schema Information
#
# Table name: data_listener_ani_carrier
#
#  id         :integer          not null, primary key
#  title      :string(200)
#  data247_id :string(32)
#  is_premium :boolean          default(FALSE)
#  is_mobile  :boolean          default(FALSE)
#

