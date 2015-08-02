class HourlyMinutesGraph
  def initialize(user)
    @user = user
  end

  def get_query
    dt = Time.now.in_time_zone('Eastern Time (US & Canada)')
    now = dt.strftime('%Y-%m-%d')
    yesterday = (dt - 1.day).strftime('%Y-%m-%d')
    last_week = (dt - 7.days).strftime('%Y-%m-%d')
    if @user.is_marketer?
      sql = "SELECT date(report_date),report_hours,total_minutes from report_total_minutes_by_hour_actual where gateway_id = '-1' and (report_date = '#{now}' OR report_date = '#{yesterday}' OR report_date = '#{last_week}')"
    else
      gateway_ids = @user.stations.map(&:id)
      if gateway_ids.present?
        sql = "SELECT date(report_date),report_hours,sum(total_minutes) from report_total_minutes_by_hour_actual where gateway_id IN (#{gateway_ids.join(',')}) and (report_date = '#{now}' OR report_date = '#{yesterday}' OR report_date = '#{last_week}') GROUP BY report_date,report_hours "
      end
    end
    sql
  end

  def results
    sql_result = get_query

    if sql_result.present?
      today_results =[]
      yesterday_results =[]
      one_week_results =[]
      sql_result =  ActiveRecord::Base.connection.execute(sql_result).to_a


      (0..23).each do |h|
        todays_data = sql_result.detect {|r| r[1] == h && r[0].strftime("%Y-%m-%d") == DateTime.now.strftime("%Y-%m-%d") }
        yesterday_data = sql_result.detect {|r| r[1] == h && r[0].strftime("%Y-%m-%d") == (DateTime.now - 1.day).strftime("%Y-%m-%d")}
        one_week_data = sql_result.detect {|r| r[1] == h && r[0].strftime("%Y-%m-%d") == (DateTime.now - 7.day).strftime("%Y-%m-%d") }

        if todays_data.present?
          today_results << [h, todays_data[2]]
        else
          today_results << [h, 0]
        end

        if yesterday_data.present?
          yesterday_results << [h, yesterday_data[2]]
        else
          yesterday_results << [h, 0]
        end

        if one_week_data.present?
          one_week_results << [h, one_week_data[2]]
        else
          one_week_results << [h, 0]
        end
      end
      results = {today: today_results, yesterday: yesterday_results, one_week: one_week_results}
    end
    results
  end
end
