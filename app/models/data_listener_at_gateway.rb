class DataListenerAtGateway < ActiveRecord::Base
  alias_attribute :gateway_id, :context_at_id
  attr_accessible :title, :gateway_id, :context_at_id, :statistics_first_session_date, :listener_id
  belongs_to :data_listener, foreign_key: :listener_id
  belongs_to :data_gateway, foreign_key: :context_at_id
  validates :listener_id, :uniqueness => { :scope => [:context_at_id]}

  ###########################################################################
  # CHART A
  # user: current user
  # number: the number of days choosing from the drop-down-box
  #         today: 0
  #         yesterday: 1
  #         7 days: 7
  #         30 days: 30
  #         All time: nil
  # gateway_id: the gateway that we want to view chart, nil for all gateways
  ###########################################################################
  def self.listeners_count(user, number = nil, gateway_id = nil)
    where_cl = number.nil? ? [] : ["statistics_first_session_date >= '#{number.to_i.send("days").ago.beginning_of_day}'"]
    where_cl = ["statistics_first_session_date >= '#{number.to_i.send("days").ago.beginning_of_day}' AND statistics_first_session_date <= '#{number.to_i.send("days").ago.end_of_day}'"] if number.to_i == 1
    if user.is_rca? || user.is_broadcaster? || user.is_marketer?
      where_cl << "gateway_id = #{gateway_id.to_i}" if gateway_id
      if( gateway_id.nil? && !user.is_marketer? ) 
        ids = DataGateway.get_for_rca_broadcast(user).map(&:id)
        if !ids.blank?
          where_cl << "gateway_id IN (#{ids.join(",")})" 
        end
      end
      new_users = self.select("distinct listener_id").count
      where_cl.pop
      return_users = self.select("distinct listener_id").count
    else
      ids = DataEntryway.find_all_by_gateway_id(gateway_id).map(&:id)
      where_cl << "entryway_id IN (#{ids.join(",")})" if gateway_id && !ids.blank?
      ids = DataEntryway.with_3rdparty(user).map(&:id)
      where_cl << "entryway_id IN (#{ids.join(",")})" if gateway_id.nil? && !ids.blank?
      new_users = DataListenerAtEntryway.select("distinct listener_id").count
      where_cl.pop
      return_users = DataListenerAtEntryway.select("distinct listener_id").count
    end
    [new_users,return_users]
  end

  ###########################################################################
  # CHART B
  # user: current user
  # gateway_id: the gateway that we want to view chart, nil for all gateways
  ###########################################################################
  def self.highlights(user, gateway_id = nil)
    if user.is_rca? || user.is_broadcaster? || user.is_marketer?
      if gateway_id
        where_cl = "gateway_id = #{gateway_id.to_i}" 
        where_gw = "context_at_id = #{gateway_id.to_i}" 
      end
      
      
      if( gateway_id.nil? && !user.is_marketer? )
        ids = DataGateway.get_for_rca_broadcast(user).map(&:id)
        if !ids.blank?
          where_cl = "gateway_id IN (#{ids.join(",")})" 
          where_gw = "context_at_id IN (#{ids.join(",")})" 
        end
      end

      if user.is_marketer? && gateway_id.blank?
        where_gw_clause = "gateway_id IS NULL"
      else
        where_gw_clause = where_cl
      end
      if gateway_id.present?
        listeners_sql = "Select total_listeners from report_listener_by_gateway_id where gateway_id = #{gateway_id}"
        listeners_res = ActiveRecord::Base.connection.execute(listeners_sql).to_a
        listeners = listeners_res.present? && !listeners_res[0].blank? ? listeners_res[0][0] : 0
      else
        listeners_sql = "Select total_listeners from report_listener_totals where sys_user_id = '#{user.id}'"
        listeners_res = ActiveRecord::Base.connection.execute(listeners_sql).to_a
        listeners = listeners_res.present? && !listeners_res[0].blank? ? listeners_res[0][0] : 0
      end

      minutes_sql = "SELECT SUM(total_minutes) FROM report_summary_listen WHERE content_id IS NULL AND #{where_gw_clause}"
      minutes_res = ActiveRecord::Base.connection.execute(minutes_sql).to_a
      minutes = minutes_res.present? && !minutes_res[0].blank? ? minutes_res[0][0] : 0

      best_day_sql = "SELECT report_date FROM `report_summary_listen` WHERE content_id IS NULL AND #{where_gw_clause} ORDER BY total_minutes DESC LIMIT 1 "
      best_day_res = ActiveRecord::Base.connection.execute(best_day_sql).to_a
      best_day = best_day_res.present? && !best_day_res.blank? ? best_day_res[0][0] : nil
    else
      if gateway_id
        where_cl = "entryway_id IN (#{DataEntryway.find_all_by_gateway_id(gateway_id).map(&:id).join(",")})"
        where_gw = "context_at_id IN (#{DataEntryway.find_all_by_gateway_id(gateway_id).map(&:id).join(",")})"
      end
      if gateway_id.nil?
        ids = DataEntryway.with_3rdparty(user).map(&:id)
        if !ids.blank?
          where_cl = "entryway_id IN (#{ids.join(",")})" 
          where_gw = "context_at_id IN (#{ids.join(",")})" 
        end
      end
      listeners = DataListenerAtEntryway.where(where_gw).select("distinct listener_id").count
      minutes = SummaryListen.where(where_cl).sum("seconds")
      # minutes = SummaryListen.select('SUM(seconds)').where(where_cl)
      max_seconds = SummaryListen.where(where_cl).maximum("seconds")
      if max_seconds
        cl = where_cl.nil? ? "seconds = #{max_seconds}" : where_cl + " AND seconds = #{max_seconds}"
        best_day = SummaryListen.where(cl).select("date").first.date
      end
    end
    [listeners,minutes,best_day || nil]
  end
  
  def self.get_total_minutes(user, gateway_id = nil)
    if user.is_rca? || user.is_broadcaster? || user.is_marketer?
      where_cl = "AND gateway_id = #{gateway_id.to_i}" if gateway_id.present?
      if gateway_id.nil? && !user.is_marketer? 
        ids = DataGateway.get_for_rca_broadcast(user).map(&:id)
        if ids.present?
          where_cl = "AND gateway_id IN (#{ids.join(",")})" 
        end
      end
      if user.is_marketer? && gateway_id.blank?
        where_gw_clause = "AND gateway_id IS NULL"
      else
        where_gw_clause = where_cl
      end
      minutes_sql = "SELECT SUM(total_minutes) FROM report_summary_listen WHERE content_id IS NULL  #{where_gw_clause}"
      minutes_res = ActiveRecord::Base.connection.execute(minutes_sql).to_a
      minutes = minutes_res.present? && !minutes_res[0].blank? ? minutes_res[0][0] : 0
    end
    minutes
  end
end



# == Schema Information
#
# Table name: data_listener_at_gateway
#
#  id                         :integer          not null, primary key
#  listener_id                :integer
#  gateway_id                 :integer
#  statistics_first_session_date              :datetime
#  status                     :string(10)
#  status_last_change_date    :datetime
#  is_frequency_listen_dialy  :boolean          default(FALSE)
#  is_frequency_listen_weekly :boolean          default(FALSE)
#  average_minutes_per_day    :integer
#  last_session_date          :datetime
#
# Indexes
#
#  fk_data_listener_at_gateway_1_idx  (listener_id)
#  fk_data_listener_at_gateway_2_idx  (gateway_id)
#  index2                             (statistics_first_session_date)
#  index3                             (status)
#  index4                             (status_last_change_date)
#  index5                             (last_session_date)
#  index8                             (is_frequency_listen_dialy,is_frequency_listen_weekly)
#

