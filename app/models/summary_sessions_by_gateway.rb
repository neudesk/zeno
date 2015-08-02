class SummarySessionsByGateway < ActiveRecord::Base
  COUNTRY = 1
  GATEWAY = 2
  ENTRYWAY = 3
  CONTENT = 4
  attr_accessible :date, :hour, :gateway_id, :country_id, :language_id,
                  :broadcast_id, :rca_id,:sessions, :sessions_acd_10sec, :sessions_acd_1min,
                  :sessions_acd_5min, :sessions_acd_20min, :sessions_acd_1hr,
                  :sessions_acd_2hr, :sessions_acd_6hr, :sessions_acd_more6hr, :seconds
  belongs_to :data_group_broadcast, foreign_key: :broadcast_id
  belongs_to :data_group_rca, foreign_key: :rca_id
  belongs_to :data_group_country, foreign_key: :country_id
  belongs_to :data_group_language, foreign_key: :language_id
  belongs_to :data_gateway, foreign_key: :gateway_id

  #####################SCOPES###########################
  scope :get_countries_report, lambda { joins(:data_group_country)
                                        .group("#{self.table_name}.country_id")
                                        .select("#{self.table_name}.country_id, sum(seconds) as total_second") }
  scope :get_countries_report_with_title, get_countries_report.group("data_group_country.title").select("data_group_country.title")
  scope :with_rca, lambda {|user| where(:rca_id => user.data_group_rca_ids)}
  scope :with_broadcast, lambda {|user| where(:broadcast_id => user.data_group_broadcast_ids)}
  ######################################################

  #####################CLASS METHODS####################

  # for country
  # options = { broken_down_by: :day/:hour, from_date: xyz, end_date: xyz }
  def self.get_report_for_country(country_id, options = {broken_down_by: :day})
    result = self.get_countries_report
                .group("date")
                .select("date")
                .order("#{self.table_name}.country_id")
                .order("date ASC")
    result = result.group("hour").select("hour") if options[:broken_down_by] == :hour
    result = result.where("date > ?", options[:from_date].to_date) if options[:from_date].present?
    result = result.where("date < ?", options[:end_day].to_date) if options[:end_day].present?
    result.where(country_id: country_id)
  end

  def self.get_report_for_gateway(country_id, options = {broken_down_by: :day}, removed_gateway_ids=[], removed_entryway_ids = [])
    result = self.get_report_for_country(country_id, options)
        .joins(:data_gateway)
        .group("obj_id, data_gateway.title")
        .select("gateway_id as obj_id, data_gateway.title, #{GATEWAY} as obj_type")
        .where("#{self.table_name}.country_id = ?", country_id)
    unless removed_gateway_ids.empty?
      result = result.where("summary_sessions_by_gateway.gateway_id NOT IN (?)", removed_gateway_ids)
      gateway_ids = DataGateway.where(id: removed_gateway_ids, country_id: country_id).map(&:id)
      unless gateway_ids.blank?
        entryways = SummarySessionsByEntryway.get_report_for_gateway(gateway_ids, options, removed_entryway_ids).select("#{ENTRYWAY} as obj_type")
        if entryways.present?
          paths = entryways.to_sql.split("FROM")
          select_arrs = paths.first.split(",")
          select_str = [select_arrs[2], select_arrs[4], select_arrs[1], select_arrs[3], select_arrs.first.split("SELECT").last,select_arrs.last].join(",")
          entryways_str = [select_str, paths.last].join(" FROM ")
          result = "(#{result.to_sql}) UNION (SELECT #{entryways_str})"
          result = self.find_by_sql(result)
        end
      end
    end
    result
  end

  def self.get_report_by_country_and_gateway(country_id, gateway_id, options = {broken_down_by: :day})
    self.get_report_for_gateway(country_id, options)
        .where(gateway_id: gateway_id)
  end
  ######################################################

  def self.get_aggregate_default(options = {broken_down_by: :day}, from_date = 7.days.ago.to_date)
    result = self.joins(:data_gateway => [:data_group_country]).group("date").select("date as called_date, sum(seconds/60) as total_minutes")

    result = result.group("hour").select("hour as called_hour") if options[:broken_down_by] == :hour

    result.where("date > ?", from_date.to_date).order("date ASC")
  end

  def self.rca_reports
    @weeks = self.get_4_weeks
    len = @weeks.length - 1
    sql = %Q{
      SELECT summary_sessions_by_gateway.rca_id, data_group_rca.title as rca_name
          FROM `summary_sessions_by_gateway`
          INNER JOIN `data_group_rca` ON `data_group_rca`.`id` = `summary_sessions_by_gateway`.`rca_id` and `data_group_rca`.`is_deleted` = false
          GROUP BY rca_id ORDER BY date asc
    }
    # sql = %Q{
    #   SELECT summary_sessions_by_gateway.rca_id, data_group_rca.title as rca_name,
    # }
    # (0..len).each do |i|
    #   item = @weeks[i]
    #   subsql = ""
    #   if i < len
    #     subsql = %Q{
    #       (
    #         select sum(summary_sessions_by_gateway.seconds)/60
    #       FROM `summary_sessions_by_gateway`
    #       INNER JOIN `data_group_rca` ON `data_group_rca`.`id` = `summary_sessions_by_gateway`.`rca_id` and `data_group_rca`.`is_deleted` = false
    #       where date(summary_sessions_by_gateway.date) >= '#{item['begin']}' and
    #       date(summary_sessions_by_gateway.date) <= '#{item['end']}'
    #       GROUP BY rca_id ORDER BY date asc
    #       ) as week#{i},
    #     }
    #   else
    #     subsql = %Q{
    #       sum(summary_sessions_by_gateway.seconds)/60 as week8
    #       FROM `summary_sessions_by_gateway`
    #       INNER JOIN `data_group_rca` ON `data_group_rca`.`id` = `summary_sessions_by_gateway`.`rca_id` and `data_group_rca`.`is_deleted` = false
    #       where date(summary_sessions_by_gateway.date) >= '#{item['begin']}' and
    #       date(summary_sessions_by_gateway.date) <= '#{item['end']}'
    #       GROUP BY rca_id ORDER BY date asc
    #     }
    #   end
    #   sql += subsql
    # end
    self.find_by_sql(sql)
  end

  def get_minutes_4_weeks
    @weeks = SummarySessionsByGateway.get_4_weeks
    len = @weeks.length - 1
    sql = %Q{
      SELECT summary_sessions_by_gateway.rca_id, data_group_rca.title as rca_name,
    }
    (0..len).each do |i|
      item = @weeks[i]
      subsql = ""
      if i < len
        subsql = %Q{
          (
            select sum(summary_sessions_by_gateway.seconds)/60
          FROM `summary_sessions_by_gateway`
          INNER JOIN `data_group_rca` ON `data_group_rca`.`id` = `summary_sessions_by_gateway`.`rca_id` and `data_group_rca`.`is_deleted` = false
          where date(summary_sessions_by_gateway.date) >= '#{item['begin']}' and
          date(summary_sessions_by_gateway.date) <= '#{item['end']}' and summary_sessions_by_gateway.rca_id = #{self.rca_id}
          GROUP BY summary_sessions_by_gateway.rca_id ORDER BY date asc
          ) as week#{i},
        }
      else
        subsql = %Q{
          sum(summary_sessions_by_gateway.seconds)/60 as week8
          FROM `summary_sessions_by_gateway`
          INNER JOIN `data_group_rca` ON `data_group_rca`.`id` = `summary_sessions_by_gateway`.`rca_id` and `data_group_rca`.`is_deleted` = false
          where date(summary_sessions_by_gateway.date) >= '#{item['begin']}' and
          date(summary_sessions_by_gateway.date) <= '#{item['end']}' and summary_sessions_by_gateway.rca_id = #{self.rca_id}
          GROUP BY summary_sessions_by_gateway.rca_id ORDER BY date asc
        }
      end
      sql += subsql
    end
    SummarySessionsByGateway.find_by_sql(sql)
  end

  def rca_gateway_report
    @weeks = SummarySessionsByGateway.get_4_weeks
    len = @weeks.length - 1
    sql = %Q{
      SELECT summary_sessions_by_gateway.rca_id, data_group_rca.title as rca_name,
    }
    (0..len).each do |i|
      item = @weeks[i]
      subsql = ""
      if i < len
        subsql = %Q{
          (
            select sum(summary_sessions_by_gateway.seconds)/60
          FROM `summary_sessions_by_gateway`
          INNER JOIN `data_group_rca` ON `data_group_rca`.`id` = `summary_sessions_by_gateway`.`rca_id` and `data_group_rca`.`is_deleted` = false
          INNER JOIN `data_gateway` ON `data_gateway`.`id` = `summary_sessions_by_gateway`.`gateway_id`
          where date(summary_sessions_by_gateway.date) >= '#{item['begin']}' and
          date(summary_sessions_by_gateway.date) <= '#{item['end']}' and summary_sessions_by_gateway.rca_id = #{self.rca_id}
          GROUP BY summary_sessions_by_gateway.rca_id ORDER BY date asc
          ) as week#{i},
        }
      else
        subsql = %Q{
          gateway_id, data_gateway.title as gateway_name, sum(summary_sessions_by_gateway.seconds)/60 as week8
          FROM `summary_sessions_by_gateway`
          INNER JOIN `data_group_rca` ON `data_group_rca`.`id` = `summary_sessions_by_gateway`.`rca_id` and `data_group_rca`.`is_deleted` = false
          INNER JOIN `data_gateway` ON `data_gateway`.`id` = `summary_sessions_by_gateway`.`gateway_id`
          where date(summary_sessions_by_gateway.date) >= '#{item['begin']}' and
          date(summary_sessions_by_gateway.date) <= '#{item['end']}' and summary_sessions_by_gateway.rca_id = #{self.rca_id}
          GROUP BY summary_sessions_by_gateway.rca_id ORDER BY date asc
        }
      end
      sql += subsql
    end
    SummarySessionsByGateway.find_by_sql(sql)
  end

  def self.get_4_weeks
    prev_month = DateTime.now - 1.month
    start = DateTime.current.beginning_of_week
    ende = DateTime.current.end_of_week

    @result = []

    (0..7).each do |i|
      @result << {
        "begin" => start.strftime("%Y-%m-%d"),
        "end" => ende.strftime("%Y-%m-%d")
      }
      start -= 1.week
      ende -= 1.week
    end

    @result.reverse
  end

  def self.rca_country_report
    @weeks = self.get_4_weeks
    len = @weeks.length - 1
    sql = %Q{
      SELECT summary_sessions_by_gateway.country_id, data_group_country.title as country_name
          FROM `summary_sessions_by_gateway`
          INNER JOIN `data_group_country` ON `data_group_country`.`id` = `summary_sessions_by_gateway`.`country_id` and
          `data_group_country`.`is_deleted` = false
          GROUP BY country_id ORDER BY date asc
    }
    self.find_by_sql(sql)
  end

  def getMinute4weeksCountry
    @weeks = SummarySessionsByGateway.get_4_weeks
    len = @weeks.length - 1
    sql = %Q{
      SELECT summary_sessions_by_gateway.country_id, data_group_country.title as country_name,
    }
    (0..len).each do |i|
      item = @weeks[i]
      subsql = ""
      if i < len
        subsql = %Q{
          (
            select sum(summary_sessions_by_gateway.seconds)/60
          FROM `summary_sessions_by_gateway`
          INNER JOIN `data_group_country` ON `data_group_country`.`id` = `summary_sessions_by_gateway`.`country_id` and `data_group_country`.`is_deleted` = false
          where date(summary_sessions_by_gateway.date) >= '#{item['begin']}' and
          date(summary_sessions_by_gateway.date) <= '#{item['end']}' and 
          summary_sessions_by_gateway.country_id = '#{self.country_id}'
          GROUP BY summary_sessions_by_gateway.country_id ORDER BY date asc
          ) as week#{i},
        }
      else
        subsql = %Q{
          sum(summary_sessions_by_gateway.seconds)/60 as week8
          FROM `summary_sessions_by_gateway`
          INNER JOIN `data_group_country` ON `data_group_country`.`id` = `summary_sessions_by_gateway`.`country_id` and `data_group_country`.`is_deleted` = false
          where date(summary_sessions_by_gateway.date) >= '#{item['begin']}' and
          date(summary_sessions_by_gateway.date) <= '#{item['end']}'
          and summary_sessions_by_gateway.country_id = '#{self.country_id}'
          GROUP BY summary_sessions_by_gateway.country_id ORDER BY date asc
        }
      end
      sql += subsql
    end
    SummarySessionsByGateway.find_by_sql(sql)
  end

  def country_gateway_report
    @weeks = SummarySessionsByGateway.get_4_weeks
    len = @weeks.length - 1
    sql = %Q{
      SELECT summary_sessions_by_gateway.country_id, data_group_country.title as country_name,
    }
    (0..len).each do |i|
      item = @weeks[i]
      subsql = ""
      if i < len
        subsql = %Q{
          (
            select sum(summary_sessions_by_gateway.seconds)/60
          FROM `summary_sessions_by_gateway`
          INNER JOIN `data_group_country` ON `data_group_country`.`id` = `summary_sessions_by_gateway`.`country_id` and
          `data_group_country`.`is_deleted` = false
          INNER JOIN `data_gateway` ON `data_gateway`.`id` = `summary_sessions_by_gateway`.`gateway_id`
          where date(summary_sessions_by_gateway.date) >= '#{item['begin']}' and
          date(summary_sessions_by_gateway.date) <= '#{item['end']}'
          and summary_sessions_by_gateway.country_id = '#{self.country_id}'
          GROUP BY summary_sessions_by_gateway.country_id ORDER BY date asc
          ) as week#{i},
        }
      else
        subsql = %Q{
          gateway_id, data_gateway.title as gateway_name, sum(summary_sessions_by_gateway.seconds)/60 as week8
          FROM `summary_sessions_by_gateway`
          INNER JOIN `data_group_country` ON `data_group_country`.`id` = `summary_sessions_by_gateway`.`country_id` and
          `data_group_country`.`is_deleted` = false
          INNER JOIN `data_gateway` ON `data_gateway`.`id` = `summary_sessions_by_gateway`.`gateway_id`
          where date(summary_sessions_by_gateway.date) >= '#{item['begin']}' and
          date(summary_sessions_by_gateway.date) <= '#{item['end']}' and
          summary_sessions_by_gateway.country_id = '#{self.country_id}'
          GROUP BY summary_sessions_by_gateway.country_id ORDER BY date asc
        }
      end
      sql += subsql
    end
    SummarySessionsByGateway.find_by_sql(sql)
  end

  def self.get_for_rca_broadcast(user)
    if user.is_rca?
      result = self.with_rca(user)
    elsif user.is_broadcaster?
      result = self.with_broadcast(user)
    end
    result
  end
end

# == Schema Information
#
# Table name: summary_sessions_by_gateway
#
#  id                   :integer          not null, primary key
#  date                 :date
#  hour                 :integer
#  gateway_id           :integer
#  country_id           :integer
#  language_id          :integer
#  rca_id               :integer
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
#  fk_summary_minutes_listen_sessions_gateway_1_idx  (gateway_id)
#  fk_summary_minutes_listen_sessions_gateway_2_idx  (country_id)
#  fk_summary_minutes_listen_sessions_gateway_3_idx  (language_id)
#  fk_summary_minutes_listen_sessions_gateway_4_idx  (rca_id)
#  fk_summary_minutes_listen_sessions_gateway_5_idx  (broadcast_id)
#

