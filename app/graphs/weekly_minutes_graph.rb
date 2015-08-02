class WeeklyMinutesGraph
  def initialize(user)
    @user = user
  end
  def results
    if @user.is_marketer?
      # sql = "SELECT report_date,WEEK(report_date,12) as week,sum(total_minutes) from report_total_minutes_by_hour
      #          WHERE report_date >= CURDATE() - INTERVAL 12 WEEK
      #          AND gateway_id IS NULL
      #          GROUP BY week"

      sql = "SELECT report_date,if(WEEK(report_date,2)<12,WEEK(report_date,2)+53,WEEK(report_date,2)) as ranking,sum(total_minutes) from report_total_minutes_by_day
               WHERE report_date >= CURDATE() - INTERVAL 12 WEEK
               AND gateway_id = -1
               GROUP BY ranking order by report_date"
    else
      gateway_ids = @user.stations.map(&:id)
      if gateway_ids.present?
        # sql = "SELECT report_date,WEEK(report_date,12) as week,sum(total_minutes) from report_total_minutes_by_hour
        #          WHERE report_date >= CURDATE() - INTERVAL 12 WEEK
        #          AND gateway_id IN (#{gateway_ids.join(',')})
        #          GROUP BY week"

        sql = "SELECT report_date,if(WEEK(report_date,2)<12,WEEK(report_date,2)+53,WEEK(report_date,2)) as ranking,sum(total_minutes) from report_total_minutes_by_day
               WHERE report_date >= CURDATE() - INTERVAL 12 WEEK
               AND gateway_id IN (#{gateway_ids.join(',')})
               GROUP BY ranking order by report_date"
      end
    end
    if sql.present?
      results =[]
      sql_result = ActiveRecord::Base.connection.execute(sql).to_a
      sql_result.each do |result|
        if result.present?
          start_day = DateTime.parse(result[0].to_s).at_beginning_of_week(:sunday).strftime("%B (%d ")
          end_day =DateTime.parse(result[0].to_s).at_end_of_week(:sunday).strftime("- %d)")
          results << [start_day + end_day, result[2]]
        end
      end
    end
    results
  end
end