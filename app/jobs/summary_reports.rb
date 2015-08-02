class SummaryReports < Struct.new(:param)
  def perform  
    p "******************************************************"
    p "----------------- Summary Reports---------------------"
    p "******************************************************"
    table_name = "report_summary_listen"
    execute_query = false
    
    if param == "RESET"
      if  !ActiveRecord::Base.connection.tables.include?(table_name)
        ActiveRecord::Schema.define(:version => 20140203143328) do
          create_table "#{table_name}", :force => true do |t|
            t.date     "report_date"
            t.integer  "total_minutes"
            t.integer  "gateway_id"
            t.integer  "content_id"
            t.datetime "created_at",    :null => false
          end
        end
      else
        sql = "TRUNCATE TABLE `#{table_name}`"
        ActiveRecord::Base.connection.execute(sql)
        execute_query = true
      end
      end_date = DateTime.now - 1.days
      where_clause = "WHERE date <= '#{end_date.strftime("%Y-%m-%d 23:59:59")}'"

    elsif param == "DAILY"
      sql = "SELECT report_date from #{table_name} ORDER BY report_date DESC LIMIT 1"
      result = ActiveRecord::Base.connection.execute(sql).to_a
      
      start_date =  Date.parse(result[0].to_s)
      end_date = (DateTime.now - 1.days).strftime("%Y-%m-%d 23:59:59")
      execute_query = true if start_date < Date.parse(end_date)
      where_clause = "WHERE date > '#{start_date.strftime("%Y-%m-%d 23:59:59")}' AND date <= '#{end_date}'"
    end
    
    if execute_query
      sql_total = "INSERT INTO #{table_name}(report_date,total_minutes,created_at) 
                    SELECT DATE(date) AS report_date,
                          sum(seconds/60) as total_minutes,
                          NOW() AS created_at
                    FROM `summary_listen` 
                    #{where_clause}
                    GROUP BY DATE(date)"
      sql_total_for_gateway = "INSERT INTO #{table_name}(report_date,total_minutes,gateway_id,created_at) 
                    SELECT DATE(date) AS report_date,
                          sum(seconds/60) as total_minutes,
                          gateway_id,
                          NOW() AS created_at
                    FROM `summary_listen`
                    #{where_clause}
                    GROUP BY gateway_id,DATE(date)"
      sql_total_for_content = "INSERT INTO #{table_name}(report_date,total_minutes,content_id,gateway_id,created_at) 
                    SELECT DATE(date) AS report_date,
                          sum(seconds/60) as total_minutes,
                          content_id,
                          gateway_id,
                          NOW() AS created_at
                    FROM `summary_listen`
                    #{where_clause}
                    GROUP BY content_id,gateway_id,DATE(date)"

      ActiveRecord::Base.connection.execute(sql_total)
      ActiveRecord::Base.connection.execute(sql_total_for_gateway)
      ActiveRecord::Base.connection.execute(sql_total_for_content)
      
      p "END TIME :"
      p Time.now
      p "******************************************************"
      p "-----------------END Summary Reports------------------"
      p "******************************************************"
    end
  end
end

