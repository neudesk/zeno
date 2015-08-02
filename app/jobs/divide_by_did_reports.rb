class DivideByDidReports < Struct.new(:param)
  def perform   
    begin
      p "START TIME :"
      p Time.now
      # *********************************************
      # ACTIVE USERS  = users who has activity in the last 30 days and TODAY
      # NEW USERS = user who has no activity in the last 30 day,but he has activity TODAY 
      # SESSION = total calls from TODAY
      # USERS BY TIME = distinct users by TODAY 
      # *********************************************
      st_date = nil
      ed_date = nil
      
      #RESET CRON JOB FUNCTIONALITY
      if param == "RESET"
        #GET THE FIRST RECORD AND LAST RECORD FROM DATABASE
        sql="SELECT concat('TRUNCATE TABLE ', TABLE_NAME, ';') FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'report_by_did_20%'"
        ActiveRecord::Base.connection.execute(sql).to_a.each do |truncate|
          ActiveRecord::Base.connection.execute(truncate[0])
        end

        start_date_sql = "SELECT date_start as start_date FROM `log_call` ORDER BY date_start ASC limit 1"
        end_date_sql = "SELECT date_start as end_date FROM `log_call` ORDER BY date_start DESC limit 1"
        
        st_date = Date.parse((ActiveRecord::Base.connection.execute(start_date_sql).to_a)[0][0].strftime("%Y-%m-%d"))
        ed_date = Date.parse((ActiveRecord::Base.connection.execute(end_date_sql).to_a)[0][0].strftime("%Y-%m-%d"))
        #        st_date = Date.parse("2013-11-01")
        #        ed_date = Date.parse("2013-11-01")
        
        
      elsif param == "DAILY"
        # DAILY CRON JOB FUNCTIONALITY
        table_name=""
        if (DateTime.now-1.days).strftime("%m") >= "01" && (DateTime.now-1.days).strftime("%m") < "07"
          table_name = "report_by_did_#{(DateTime.now-1.days).strftime('%Y')}_1"
        else
          table_name = "report_by_did_#{(DateTime.now-1.days).strftime('%Y')}_2"
        end
        
        if ActiveRecord::Base.connection.tables.include?(table_name)
          start_date_sql = "SELECT report_date FROM `#{table_name}` ORDER BY report_date DESC LIMIT 1"
          first_date = (ActiveRecord::Base.connection.execute(start_date_sql).to_a)
          
          if first_date.present? && first_date[0][0].present?
            st_date= Date.parse(first_date[0][0].to_s)+1.days
            ed_date = DateTime.now-1.days
          else
            st_date = DateTime.now.at_beginning_of_month
            ed_date = DateTime.now-1.days
          end
        else 
          ActiveRecord::Schema.define(:version => 20140203143328) do
            create_table "#{table_name}", :force => true do |t|
              t.date     "report_date"
              t.integer  "active_users"
              t.integer  "new_users"
              t.integer  "users_by_time"
              t.integer  "sessions"
              t.integer  "total_minutes"
              t.integer  "entryway_id"
              t.datetime "created_at",    :null => false

            end
          end
          
          st_date= DateTime.now-1.days
          ed_date = DateTime.now -1.days
        end
      end
      p "******************************************************"
      p "----------------REPORTS BY DID AGGREGATE TABLE-------------- "
      p "******************************************************"
      st_date.upto(ed_date) {|end_date|

        if end_date.strftime("%m") >= "01" && end_date.strftime("%m") < "07"
          table_name = "report_by_did_#{end_date.strftime('%Y')}_1"
        else
          table_name = "report_by_did_#{end_date.strftime('%Y')}_2"
        end
        
        if  !ActiveRecord::Base.connection.tables.include?(table_name)
          ActiveRecord::Schema.define(:version => 20140203143328) do
            create_table "#{table_name}", :force => true do |t|
              t.date     "report_date"
              t.integer  "active_users"
              t.integer  "new_users"
              t.integer  "users_by_time"
              t.integer  "sessions"
              t.integer  "total_minutes"
              t.integer  "entryway_id"
              t.datetime "created_at",    :null => false

            end
          end
        end

        p "------------------------------"
        p "Processing date : #{end_date}"
        p "------------------------------"
        
        day = end_date.strftime("%-d")
        start_date = end_date - 30.days
        end_month = end_date.strftime("%m")
        start_month = start_date.strftime("%m")
        end_year = end_date.strftime("%Y")
        start_year = start_date.strftime("%Y")
        
        session_by_did_sql = "SELECT entryway_id,COUNT(entryway_id) as sessions from log_call_#{end_year}_#{end_month}
                              WHERE date_start >= '#{end_date.strftime('%Y-%m-%d 00:00:00')}' AND date_start <= '#{end_date.strftime('%Y-%m-%d 23:59:59')}'
                              GROUP BY entryway_id"          
       
        users_by_did_sql = "SELECT entryway_id,COUNT(distinct listener_id) as users_sum FROM log_call_#{end_year}_#{end_month}
                            WHERE date_start >= '#{end_date.strftime('%Y-%m-%d 00:00:00')}' AND date_start <= '#{end_date.strftime('%Y-%m-%d 23:59:59')}'
                            GROUP BY entryway_id"
      
        total_minutes_sql = "SELECT entryway_id,sum(seconds/60) as total_minutes from  `summary_listen` 
                             WHERE `date` >= '#{end_date.strftime('%Y-%m-%d 00:00:00')}' AND `date` <= '#{end_date.strftime('%Y-%m-%d 23:59:59')}'
                             GROUP BY entryway_id"
       

        current_day_ids_sql = "SELECT distinct (listener_id),entryway_id FROM `log_call_#{end_year}_#{end_month}`
                               WHERE date_start >= '#{end_date.strftime('%Y-%m-%d 00:00:00')}' AND date_start <= '#{end_date.strftime('%Y-%m-%d 23:59:59')}'
                               GROUP BY entryway_id,listener_id;"
        
        if (ActiveRecord::Base.connection.tables.include?("log_call_#{start_year}_#{start_month}"))
          last_days_ids_sql = "SELECT  distinct listener_id,entryway_id FROM `log_call_#{start_year}_#{start_month}`  
                              WHERE  date_start >= '#{start_date.strftime('%Y-%m-%d 00:00:00')}' group by entryway_id,listener_id  
                              UNION ALL 
                              SELECT distinct listener_id,entryway_id  FROM `log_call_#{end_year}_#{end_month}` 
                              WHERE  date_start < '#{end_date.strftime('%Y-%m-%d 00:00:00')}' group by entryway_id,listener_id;"

        else
          last_days_ids_sql = "SELECT distinct listener_id,entryway_id  FROM `log_call_#{end_year}_#{end_month}` 
                              WHERE  date_start < '#{end_date.strftime('%Y-%m-%d 00:00:00')}' group by entryway_id,listener_id;"
        end

        session_by_did = ActiveRecord::Base.connection.execute(session_by_did_sql).to_a
        users_by_did = ActiveRecord::Base.connection.execute(users_by_did_sql).to_a   
        total_minutes_by_did = ActiveRecord::Base.connection.execute(total_minutes_sql).to_a
        last_days_ids = ActiveRecord::Base.connection.execute(last_days_ids_sql).to_a 
        current_day_ids = ActiveRecord::Base.connection.execute(current_day_ids_sql).to_a 
        results = []
        
        session_by_did.each do |sessions|
          new_user=0
          active_user = 0
          
          last_entryway_ids_res = []
          last_entryway_ids = last_days_ids.select {|id| id[1]==sessions[0]}
          last_entryway_ids.each { |item|  last_entryway_ids_res << item[0] } if last_entryway_ids.present?

          current_entryway_ids_res = []
          current_entryway_ids = current_day_ids.select {|id| id[1]==sessions[0]}
          current_entryway_ids.each { |item|  current_entryway_ids_res << item[0] } if current_entryway_ids.present?

          current_entryway_ids_res = current_entryway_ids_res.present? ? current_entryway_ids_res.uniq : nil
          last_entryway_ids_res = last_entryway_ids_res.present? ? last_entryway_ids_res.uniq  : nil
          
          total_minutes  = total_minutes_by_did.detect {|t| t[0] == sessions[0]}
          users_by_time = users_by_did.detect {|s| s[0] == sessions[0] } 
          
          if current_entryway_ids_res.present? && last_entryway_ids_res.present?
            active_user = (current_entryway_ids_res & last_entryway_ids_res).count
          else
            active_user = 0 
          end
          
          new_user = users_by_time[1] - active_user
          results << "('#{end_date}','#{active_user}','#{new_user}', '#{users_by_time.present? ? users_by_time[1] : 0}','#{sessions[1]}','#{total_minutes.present? ? total_minutes[1] : 0 }', '#{sessions[0]}','#{Time.now.to_s(:db)}')"
        
        end
        
        if results.present?
          sql_insert_gateways = "INSERT INTO #{table_name}( report_date,
                                                            active_users,
                                                            new_users,
                                                            users_by_time,
                                                            sessions,
                                                            total_minutes,
                                                            entryway_id,
                                                            created_at) VALUES #{results.join(',')}"
          ActiveRecord::Base.connection.execute(sql_insert_gateways)
        end
      }
      p "END TIME :"
      p Time.now
      p "******************************************************"
      p "----------------END REPORTS BY DID AGGREGATE TABLE---------- "
      p "******************************************************"
    rescue => error
      p error.message
    end
  end
end