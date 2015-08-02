class TotalMinutesByHourReports < Struct.new(:param)
  def perform  
    p "******************************************************"
    p "----------- Total Minutes By Hour Reports-------------"
    p "******************************************************"
    
    p "START TIME :"
    p Time.now
    
    table_name = "report_total_minutes_by_hour"
    if  !ActiveRecord::Base.connection.tables.include?(table_name)
      ActiveRecord::Schema.define(:version => 20140203143328) do
        create_table "#{table_name}", :force => true do |t|
          t.integer   "report_hours"
          t.integer  "total_minutes"
          t.integer  "gateway_id"
          t.datetime "created_at",    :null => false
          t.datetime "report_date",    :null => false
        end
      end
    end
    date = DateTime.now 
    
    sql = "TRUNCATE TABLE `#{table_name}`"
    ActiveRecord::Base.connection.execute(sql)
    
  

    sql_total = " INSERT INTO #{table_name}(report_date,report_hours,total_minutes,created_at) 
                  SELECT DATE(date),HOUR(date) as report_hours,
                        sum(seconds/60) as total_minutes,
                        NOW() as created_at
                  FROM `summary_listen` 
                  WHERE date > '#{(date-43.day).strftime("%Y-%m-%d 23:59:59")}' AND date <= '#{date.strftime("%Y-%m-%d 23:59:59")}'
                  GROUP BY DATE(date),HOUR(date)"
    
    sql_total_for_gateway = " INSERT INTO #{table_name}(report_date,report_hours,total_minutes,gateway_id,created_at) 
                              SELECT DATE(date),HOUR(date) as report_hours,
                                    sum(seconds/60) as total_minutes,
                                    gateway_id,
                                    NOW() AS created_at
                              FROM `summary_listen`
                              WHERE date > '#{(date-43.day).strftime("%Y-%m-%d 23:59:59")}' AND date <= '#{date.strftime("%Y-%m-%d 23:59:59")}'
                              GROUP BY gateway_id,DATE(date),HOUR(date)"

    ActiveRecord::Base.connection.execute(sql_total)
    ActiveRecord::Base.connection.execute(sql_total_for_gateway)
  
    p "END TIME :"
    p Time.now
      
    p "******************************************************"
    p "-----------END Total Minutes By Hour Reports----------"
    p "******************************************************"
  end
end
