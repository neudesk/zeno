class SummaryListen < ActiveRecord::Base
  attr_accessible :date, :entryway_id, :gateway_id, :content_id, :count, :count_acd_10sec, :count_acd_1min, :count_acd_5min, :count_acd_20min, :count_acd_1hr, :count_acd_2hr, :count_acd_6hr, :count_acd_more6hr, :seconds
  belongs_to :data_gateway, foreign_key: :gateway_id
  belongs_to :data_entryway, foreign_key: :entryway_id
  belongs_to :data_content, foreign_key: :content_id

  scope :get_countries_report, lambda { joins(:data_gateway => :data_group_country)
    .group("data_gateway.country_id")
    .select("data_gateway.country_id, sum(seconds) as total_second") }
  scope :get_countries_report_with_title, get_countries_report.group("data_group_country.title").select("data_group_country.title")

  COUNTRY = 1
  GATEWAY = 2
  ENTRYWAY = 3
  CONTENT = 4

  def self.rca_reports
    @weeks = self.get_4_weeks
    len = @weeks.length - 1
    sql = %Q{
      SELECT data_gateway.rca_id, data_group_rca.title as rca_name
          FROM `summary_listen`
          INNER JOIN data_gateway ON `data_gateway`.`id` = `summary_listen`.`gateway_id`
          INNER JOIN `data_group_rca` ON `data_group_rca`.`id` = `data_gateway`.`rca_id` and `data_group_rca`.`is_deleted` = false
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
    #       where date(summary_sessions_by_gateway.date) >= '#{item['begin']}' andp "*************************************"
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

  def self.get_aggregate(options = {broken_down_by: :day}, from_date=1.week.ago.to_date)
    result = self.joins(:data_entryway => [:data_group_country, :data_gateway]).group("date").select("date as called_date, sum(seconds/60) as total_minutes")

    #TODO: update after find the solution for hour info
    result = result.group("hour").select("hour as called_hour") if options[:broken_down_by] == :hour

    result.where("date > ?", from_date.to_date).order("date ASC")
  end

  def self.get_report
    self.joins(:data_entryway).group("data_entryway.did_e164").select("data_entryway.did_e164 as title")
    .group("#{self.table_name}.entryway_id, date, data_entryway.country_id")
    .select("date,hour(date) as hour, data_entryway.country_id,#{self.table_name}.entryway_id as obj_id, sum(seconds) as total_second")
    .order("date ASC")
  end

  # for entryway
  # options = { broken_down_by: :day/:hour, from_date: xyz, end_date: xyz }
  def self.get_report_by_entryway_id(entryway_id, options = {broken_down_by: :day})
    result = get_report.joins(:data_entryway).group("data_entryway.gateway_id").select("data_entryway.gateway_id")
    #TODO: update after find the solution for hour info
    result = result.group("hour") if options[:broken_down_by] == :hour
    result = result.where("date > ?", options[:from_date].to_date) if options[:from_date].present?
    result = result.where("date > ?", options[:end_date].to_date) if options[:end_date].present?
    result.where("#{self.table_name}.entryway_id = ?", entryway_id)
    result
    
  end

  def self.get_report_by_country_and_gateway(country_id, gateway_id, options = {broken_down_by: :day})
    self.get_report_for_gateway(country_id, options)
    .where(gateway_id: gateway_id)
  end

  #TODO: maybe loop, check again
  def self.get_report_for_gateway(country_id, options = {broken_down_by: :day}, removed_gateway_ids=[], removed_entryway_ids = [])
    result = self.get_report_for_country(country_id, options)
    .joins(:data_gateway)
    .group("obj_id, data_gateway.title")
    .select("gateway_id as obj_id, data_gateway.title, #{GATEWAY} as obj_type")
    #.where("#{self.table_name}.country_id = ?", country_id)
    unless removed_gateway_ids.empty?
      result = result.where("summary_listen.gateway_id NOT IN (?)", removed_gateway_ids)
      gateway_ids = DataGateway.where(id: removed_gateway_ids, country_id: country_id).map(&:id)
      unless gateway_ids.blank?
        entryways = self.get_report_for_gateway(gateway_ids, options, removed_entryway_ids).select("#{ENTRYWAY} as obj_type")
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

  def self.get_aggregate_default(options = {broken_down_by: :day}, from_date = 7.days.ago.to_date)
    result = self.joins(:data_gateway => [:data_group_country]).group("date").select("date as called_date, sum(seconds/60) as total_minutes")

    #TODO: update after find the solution for hour info
    result = result.group("hour").select("hour as called_hour") if options[:broken_down_by] == :hour

    result.where("date > ?", from_date.to_date).order("date ASC")
  end

  def self.rca_country_report
    @weeks = self.get_4_weeks
    len = @weeks.length - 1
    sql = %Q{
      SELECT data_gateway.country_id, data_group_country.title as country_name
          FROM `summary_listen`
          INNER JOIN `data_gateway` ON `data_gateway`.`id` = `summary_listen`.`gateway_id`
          INNER JOIN `data_group_country` ON `data_group_country`.`id` = `data_gateway`.`country_id` and
          `data_group_country`.`is_deleted` = false
          GROUP BY data_gateway.country_id ORDER BY summary_listen.date asc
    }
    self.find_by_sql(sql)
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

  # for country
  # options = { broken_down_by: :day/:hour, from_date: xyz, end_date: xyz }
  def self.get_report_for_country(country_id, options = {broken_down_by: :day})
    result = self.get_countries_report
    .group("date")
    .select("date")
    .order("data_gateway.country_id")
    .order("date ASC")
    result = result.group("hour").select("hour") if options[:broken_down_by] == :hour
    result = result.where("date > ?", options[:from_date].to_date) if options[:from_date].present?
    result = result.where("date < ?", options[:end_day].to_date) if options[:end_day].present?
    result.where("data_gateway.country_id = ?", country_id)
  end

  def self.get_average_time_per_user 
    sum_hour_select_to_7_weeks = []
    8.times do |t|
      start_date = t == 0 ? Date.today.beginning_of_week : t.weeks.ago.beginning_of_week
      end_date = t == 0 ? Date.today.beginning_of_week : t.weeks.ago.end_of_week
      sum_hour_select_to_7_weeks << <<-EOF
        (SELECT sum(seconds)
        FROM summary_listen 
        INNER JOIN data_content as sub_dc ON sub_dc.id = summary_listen.content_id
        INNER JOIN data_group_country as sub_c ON sub_c.id = sub_dc.country_id
        WHERE (date >= '#{start_date}' AND date <= '#{end_date}' AND sub_dc.id = dc.id AND c.id = sub_c.id) 
        ORDER BY radio_name) as week_#{t}
      EOF
    end

    self.joins("INNER JOIN data_content as dc ON dc.id = summary_listen.content_id
                INNER JOIN data_group_country as c ON c.id = dc.country_id")
    .select("dc.title as radio_name, c.title as country_name, #{sum_hour_select_to_7_weeks.join(" , ")}")
    .group("dc.title, c.title")
    .order("radio_name")
  end


  def self.listeners_count(user, number = 7, gateway_id = nil, entryway_id = nil)
    begin
      result = []
      where_cl = ["date >= '#{number.to_i.send("days").ago}'"]
      if user.is_thirdparty?
        if entryway_id.nil?
          ids = nil
          if gateway_id && !ids.nil?
            ids = DataEntryway.find_all_by_gateway_id(gateway_id).map(&:id)
            where_cl << "entryway_id IN (#{ids.join(",")})"
          end

          if gateway_id.nil? && !ids.nil?
            ids = DataEntryway.with_3rdparty(user).map(&:id)
            where_cl << "entryway_id IN (#{ids.join(",")})"
          end

        else
          where_cl << "entryway_id = #{entryway_id.to_i}"
        end
      else
        if gateway_id
          where_cl << "gateway_id = #{gateway_id}"
        else
          if !user.is_marketer? && !ids.nil?
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
    rescue 
      
    end
  end

  def self.count_for_wday(relations, wday, day)
    for_new = relations.select{|x| x.date.wday == wday}.map{|y| y.active_by_new.to_i}.sum
    for_return = relations.select{|x| x.date.wday == wday}.map{|y| y.active_by_return.to_i}.sum
    [day, for_return + for_new]
  end

  def self.minutes_count(user,number = 7, gateway_id = nil, content_id = nil)
    begin
      where_cl = (number == 0) ? [] : ["date >= '#{number.to_i.send("days").ago.strftime('%Y-%m-%d 00:00:00')}'"]
      content_ids = content_id.nil? ? DataContent.get_channels(user, nil, 'id') : [content_id]
      if !user.is_marketer?
        where_cl << "content_id IN (#{content_ids.join(",")}) " unless content_ids.blank?
        where_cl << "gateway_id = '#{gateway_id}'" if gateway_id.present? && gateway_id != "null"
        relations = self.where(where_cl.join(" AND ")).select("sum(seconds),DATE(date)").group("DAY(date)") 
      else
        where_cl << "gateway_id = '#{gateway_id}'" if gateway_id.present? && gateway_id != "null" && content_id.nil?
        where_cl << "content_id = '#{content_id}'" if content_id.present?
        relations = self.where(where_cl.join(" AND ")).select("sum(seconds),DATE(date)").group("DAY(Date)") 
      end
      #      p relations.to_sql
      result = []
      relations.each do |row|
        result << [row[1].strftime('%a %e').to_s, (row[0].to_f)/60]
      end
      result
      #get_totals_chart_days(relations,number)
    rescue
    end
  end

  def self.count_seconds_for_wday(relations, wday, day)
    seconds = relations.select{|x| x.date.strftime('%a %e').to_s == day}.map{|y| y.seconds.to_i}.sum
    [day, (seconds.to_f/60).round(2)]
  end
  
  def self.get_totals_chart_days(relations,no_of_days)
    result= []
    date = Date.today
    days_of_week = (date-no_of_days.days..date).to_a
    days_of_week.each_with_index do |day,index|
      result << count_seconds_for_wday(relations, day.wday, day.strftime('%a %e').to_s)
    end
    result  
  end
  
  def self.report_minutes(user,number = 0, gateway_id = nil, content_id = nil)
    begin
      where_cl = (number == 0) ? [["date >= '#{Date.today.at_beginning_of_month.strftime('%Y-%m-%d 00:00:00')}'"]] 
      : ["date >= '#{number.month.ago.beginning_of_month.strftime('%Y-%m-%d 00:00:00')}' AND date <= '#{number.month.ago.end_of_month.strftime('%Y-%m-%d 00:00:00')}'"]
      content_ids = content_id.nil? ? DataContent.get_channels(user, nil, 'id') : [content_id]
      if !user.is_marketer?
        where_cl << "content_id IN (#{content_ids.join(",")}) " unless content_ids.blank?
        where_cl << "gateway_id = '#{gateway_id}'" if gateway_id.present? && gateway_id != "null"
        relations = self.where(where_cl.join(" AND ")).select("sum(seconds),date").group('date') 
      else
        where_cl << "gateway_id = '#{gateway_id}'" if gateway_id.present? && gateway_id != "null" && content_id.nil?
        where_cl << "content_id = '#{content_id}'" if content_id.present?
        relations = self.where(where_cl.join(" AND ")).select("sum(seconds) as seconds,date").group('date')  
      end
      #      p relations.to_sql
      result= []
      (number.month.ago.beginning_of_month.strftime('%d')..number.month.ago.end_of_month.strftime('%d')).each do |day|
        result << [day,(relations.select{|x| x.date.strftime('%d') == day}.map{|y| y.seconds.to_i}.sum/60).round(2)]
      end
      result
    rescue
    end
  end
  
end