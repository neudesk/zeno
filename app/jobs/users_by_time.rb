class UsersByTime < Struct.new(:param)
  def perform   
    begin
      table_name = "report_users_by_time"
      if  !ActiveRecord::Base.connection.tables.include?(table_name)
        ActiveRecord::Schema.define(:version => 20140203143328) do
          create_table "#{table_name}", :force => true do |t|
            t.date     "report_date"
            t.integer  "report_hours"
            t.integer  "users_by_time"
            t.integer  "gateway_id"
            t.datetime "created_at",    :null => false
          end
        end
      end
      sql = "TRUNCATE TABLE `report_users_by_time`"
      ActiveRecord::Base.connection.execute(sql)
      
      start_date = DateTime.now
      # if end_date==DateTime.now.strftime("%Y-%m-%d")
      #User BY TIME FOR TODAY
      
      p "*******************************************************************"
      p "Processing date from Users by time \n Start at : #{Time.now.to_s(:db)}"
      p "*******************************************************************"

      gateways_users_by_time_today_sql = "SELECT count(DISTINCT log_call.listener_id) as count, hour(log_call.date_start) as `hour`, 
                    gateway_id  FROM `log_call` WHERE (date_start >= '#{start_date.strftime("%Y-%m-%d")} 00:00:00' AND date_start <= '#{start_date.strftime("%Y-%m-%d")} 23:59:59') 
                    GROUP BY `hour`,gateway_id ORDER BY hour"
      gateways_users_by_time_yestarday_sql = "SELECT count(DISTINCT log_call.listener_id) as count, hour(log_call.date_start) as `hour`, 
                    gateway_id  FROM `log_call` WHERE (date_start >= '#{(start_date-1.days).strftime("%Y-%m-%d")} 00:00:00' AND date_start <= '#{(start_date-1.days).strftime("%Y-%m-%d")} 23:59:59') 
                    GROUP BY `hour`,gateway_id ORDER BY hour"
      
      total_users_by_time_today_sql = "SELECT count(DISTINCT log_call.listener_id) as count, hour(log_call.date_start) as `hour`
                     FROM `log_call` WHERE (date_start >= '#{start_date.strftime("%Y-%m-%d")} 00:00:00' AND date_start <= '#{start_date.strftime("%Y-%m-%d")} 23:59:59') 
                    GROUP BY `hour` ORDER BY `hour`"	
      total_users_by_time_yestarday_sql = "SELECT count(DISTINCT log_call.listener_id) as count, hour(log_call.date_start) as `hour` 
                   FROM `log_call` WHERE (date_start >= '#{(start_date-1.days).strftime("%Y-%m-%d")} 00:00:00' AND date_start <= '#{(start_date-1.days).strftime("%Y-%m-%d")} 23:59:59') 
                    GROUP BY `hour` ORDER BY `hour`"
      
      gateways_users_by_time_today = ActiveRecord::Base.connection.execute(gateways_users_by_time_today_sql).to_a
      gateways_users_by_time_yestarday = ActiveRecord::Base.connection.execute(gateways_users_by_time_yestarday_sql).to_a
      total_users_by_time_today = ActiveRecord::Base.connection.execute(total_users_by_time_today_sql).to_a
      total_users_by_time_yestarday = ActiveRecord::Base.connection.execute(total_users_by_time_yestarday_sql).to_a

      values = []
      gateways_users_by_time_today.each do |g|
        values << "('#{start_date}', '#{g[1]}', '#{g[0]}', '#{g[2]}','#{Time.now.to_s(:db)}') "
      end

      p "gateway count today : #{gateways_users_by_time_today.length.to_s}"
      gateways_users_by_time_yestarday.each do |g|
        values << "('#{start_date-1.days}', '#{g[1]}', '#{g[0]}', '#{g[2]}','#{Time.now.to_s(:db)}') "
      end
      p "gateway count yestarday : #{gateways_users_by_time_yestarday.length.to_s}"
      p "*********************************************************************"
      total_users_by_time_today.each do |t|
        values << "('#{start_date}', #{t[1]}, '#{t[0]}', '#{t[2]}','#{Time.now.to_s(:db)}') "
        p "total users for today count at #{t[1]}: #{t[0]}"
      end

      total_users_by_time_yestarday.each do |t|
        values << "('#{start_date-1.days}', '#{t[1]}', '#{t[0]}', '#{t[2]}','#{Time.now.to_s(:db)}') "
        p "total users for yestarday count at #{t[1]}: #{t[0]}"
      end

      sql = "INSERT INTO #{table_name}(report_date, report_hours, users_by_time, gateway_id, created_at ) VALUES #{values.join(',')}"
      ActiveRecord::Base.connection.execute(sql)
      # end
      p "*******************************************************************"
    rescue => error
      p error.message
    end
  end
end