class SessionController< ApplicationController
  def index
    
  end
  
  def  get_sessions

    if (DateTime.now-1.days).strftime("%m") >= "01" && (DateTime.now-1.days).strftime("%m") < "07"
      old_table_name = "report_#{((DateTime.now - 1.day) - 6.month).strftime('%Y')}_2"
      current_table_name = "report_#{(DateTime.now-1.days).strftime('%Y')}_1"
    else
      old_table_name = "report_#{((DateTime.now - 1.day) - 6.month).strftime('%Y')}_1"
      current_table_name = "report_#{(DateTime.now-1.days).strftime('%Y')}_2"
    end
    if params[:type]== "daily"
      if current_user.is_marketer?
        sql = " (SELECT report_date ,sum(total_minutes) from #{old_table_name} where  gateway_id IS NULL
               AND report_date >= '#{(DateTime.now - 7.day).strftime("%Y-%m-%d")}' and report_date < '#{DateTime.now.strftime("%Y-%m-%d")}' GROUP BY report_date)
              UNION ALL
              (SELECT report_date ,sum(total_minutes) from #{current_table_name} where  gateway_id IS NULL
               AND report_date >= '#{(DateTime.now - 7.day).strftime("%Y-%m-%d")}' and report_date < '#{DateTime.now.strftime("%Y-%m-%d")}' GROUP BY report_date)"
      else
        gateway_ids = current_user.stations.map(&:id)
        if gateway_ids.present?
          sql = " (SELECT report_date,sum(total_minutes) from #{old_table_name} where  gateway_id IN (#{gateway_ids.join(',')})
               AND report_date >= '#{(DateTime.now - 7.day).strftime("%Y-%m-%d")}' and report_date < '#{DateTime.now.strftime("%Y-%m-%d")}' group by report_date)
              UNION ALL
              (SELECT report_date,sum(total_minutes) from #{current_table_name} where gateway_id IN (#{gateway_ids.join(',')}) 
               AND report_date >= '#{(DateTime.now - 7.day).strftime("%Y-%m-%d")}' and report_date < '#{DateTime.now.strftime("%Y-%m-%d")}' GROUP BY report_date)"
        end
      end
      
      if sql.present?
        results =[]
        sql_result =  ActiveRecord::Base.connection.execute(sql).to_a 
        sql_result.each do |result|
          if result.present?
            results << [DateTime.parse(result[0].to_s).strftime("%e %a"), result[1]]
          end
        end
      end
      
    elsif params[:type]== "weekly"
      if current_user.is_marketer?
        sql = " (SELECT WEEK(report_date,6) as week ,sum(total_minutes) from #{old_table_name} where  gateway_id IS NULL
               AND report_date >= CURDATE() - INTERVAL 6 WEEK GROUP BY week)
              UNION ALL
              (SELECT WEEK(report_date,6) as week ,sum(total_minutes) from #{current_table_name} where  gateway_id IS NULL
               AND report_date >= CURDATE() - INTERVAL 6 WEEK GROUP BY week)"
      else
        gateway_ids = current_user.stations.map(&:id)
        if gateway_ids.present?
          sql = " (SELECT WEEK(report_date,6) as week ,sum(total_minutes) from #{old_table_name} where  gateway_id IN (#{gateway_ids.join(',')})
               AND report_date >= CURDATE() - INTERVAL 6 WEEK GROUP BY week)
              UNION ALL
              (SELECT WEEK(report_date,6) as week ,sum(total_minutes) from #{current_table_name} where gateway_id IN (#{gateway_ids.join(',')}) 
               AND report_date >= CURDATE() - INTERVAL 6 WEEK GROUP BY week)"
        end
      end
      
      if sql.present?
        results =[]
        sql_result =  ActiveRecord::Base.connection.execute(sql).to_a 
        sql_result.each do |result|
          if result.present?
            if result[0].to_i == 1
              results << [ result[0].to_s + "st week" ,  result[1]]
            elsif result[0].to_i == 2
              results << [ result[0].to_s + "nd week" ,  result[1]]
            elsif result[0].to_i == 3
              results << [ result[0].to_s + "rd week" ,  result[1]]
            else
              results << [ result[0].to_s + "th week" ,  result[1]]
            end
          end
        end
      end
      
    elsif params[:type]== "monthly"
      if current_user.is_marketer?
        sql = " (SELECT MONTH(report_date) as month ,sum(total_minutes) from #{old_table_name} where  gateway_id IS NULL
               AND report_date >= CURDATE() - INTERVAL 6 MONTH GROUP BY month)
              UNION ALL
              (SELECT MONTH(report_date) as month ,sum(total_minutes) from #{current_table_name} where  gateway_id IS NULL
               AND report_date >= CURDATE() - INTERVAL 6 MONTH GROUP BY month)"
      else
        gateway_ids = current_user.stations.map(&:id)
        if gateway_ids.present?
          sql = " (SELECT MONTH(report_date) as month ,sum(total_minutes) from #{old_table_name} where  gateway_id IN (#{gateway_ids.join(',')})
               AND report_date >= CURDATE() - INTERVAL 6 MONTH GROUP BY month)
              UNION ALL
              (SELECT MONTH(report_date) as month ,sum(total_minutes) from #{current_table_name} where gateway_id IN (#{gateway_ids.join(',')}) 
               AND report_date >= CURDATE() - INTERVAL 6 MONTH GROUP BY month)"
        end
      end
      
      if sql.present?
        results =[]
        sql_result =  ActiveRecord::Base.connection.execute(sql).to_a 
        months = [[1, "January"],[2, "February"],[3, "March"],[4, "April"],[5, "May"],[6, "June"],[7, "July"],[8, "July"],[9, "September"],[10, "October"],[11, "November"],[12, "December"]]
        sql_result.each do |result|
          if result.present?
            results << [months.detect{|m| result[0] == m[0]}[1], result[1]]
          end
        end
      end
    end
      

    render :json => results 
  end
end
