class DailyMinutesGraph
  def initialize(user)
    @user = user
  end

  def results
    if @user.is_marketer?
      sql = "SELECT date(report_date),sum(total_minutes) from report_total_minutes_by_day
            WHERE gateway_id = '-1' AND
            (report_date > '#{(DateTime.now - 15.day).strftime("%Y-%m-%d")}' AND report_date < '#{DateTime.now.strftime("%Y-%m-%d")}')
            GROUP BY report_date"
    else
      gateway_ids = @user.stations.map(&:id)
      if gateway_ids.present?
        sql = "SELECT date(report_date),sum(total_minutes) from report_total_minutes_by_day
              WHERE gateway_id IN (#{gateway_ids.join(',')}) AND
              (report_date > '#{(DateTime.now - 15.day).strftime("%Y-%m-%d")}' AND report_date < '#{DateTime.now.strftime("%Y-%m-%d")}')
              GROUP BY report_date"
      end
    end
    if sql.present?
      sql_result =  ActiveRecord::Base.connection.execute(sql).to_a
      one_week_results =[]
      current_week_results =[]

      (1..7).each do |h|
        one_week_data = sql_result.detect {|r| r[0].strftime("%Y-%m-%d") == (DateTime.now - (h+7).day).strftime("%Y-%m-%d")}
        if one_week_data.present?
          one_week_results << [8-h, one_week_data[1], DateTime.parse(one_week_data[0].to_s).strftime("%a %e")]
        else
          date = DateTime.now - 8.days - h.days
          one_week_results << [8-h, 0, date.strftime("%a %e")]
        end

        current_week_data = sql_result.detect {|r| r[0].strftime("%Y-%m-%d") == (DateTime.now - h.day).strftime("%Y-%m-%d")}
        if current_week_data.present?
          current_week_results << [8-h, current_week_data[1], DateTime.parse(current_week_data[0].to_s).strftime("%a %e")]
        else
          date = DateTime.now - h.days
          current_week_results << [8-h, 0, date.strftime("%a %e")]
        end
      end
    {:current_week => current_week_results, :one_week => one_week_results}
    end
  end
end