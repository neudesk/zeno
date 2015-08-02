class LogCallPartitioning < Struct.new(:param)
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
        sql="SELECT concat('TRUNCATE TABLE ', TABLE_NAME, ';') FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'log_call_20%'"
        ActiveRecord::Base.connection.execute(sql).to_a.each do |truncate|
          ActiveRecord::Base.connection.execute(truncate[0])
        end

        start_date_sql = "SELECT date_start as start_date FROM `log_call` ORDER BY date_start ASC limit 1"
        end_date_sql = "SELECT date_start as end_date FROM `log_call` ORDER BY date_start DESC limit 1"
        
        st_date = Date.parse((ActiveRecord::Base.connection.execute(start_date_sql).to_a)[0][0].strftime("%Y-%m-%d"))
        ed_date = Date.parse((ActiveRecord::Base.connection.execute(end_date_sql).to_a)[0][0].strftime("%Y-%m-%d"))
        # st_date = Date.parse("2013-10-10")
        #ed_date = Date.parse("2013-10-10")
        
        
      elsif param == "DAILY"
        # DAILY CRON JOB FUNCTIONALITY
        
        # table_name = "log_call_#{DateTime.now.strftime('%Y')}_#{(DateTime.now-1.days).strftime('%m')}"
        table_name = "log_call_#{(DateTime.now - 1.days).in_time_zone('Eastern Time (US & Canada)').strftime('%Y')}_#{(DateTime.now-1.days).strftime('%m')}"

        if ActiveRecord::Base.connection.tables.include?(table_name)
          start_date_sql = "SELECT date_start FROM `#{table_name}` ORDER BY date_start DESC LIMIT 1"
          first_date = ActiveRecord::Base.connection.execute(start_date_sql).to_a
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
              t.date     "date_start"
              t.integer  "listener_id"
              t.integer  "gateway_id"
              t.integer  "entryway_id"
              # t.integer  "seconds"
             # t.integer  "ani_e164"
            end
          end
          index_sql = "CREATE INDEX date_start ON #{table_name}(date_start)"
          ActiveRecord::Base.connection.execute(index_sql)
          st_date = DateTime.now.at_beginning_of_month
          ed_date = DateTime.now - 1.days
        end
      end
      p "******************************************************"
      p "----------------PARTITIONING LOG_CALL-------------- "
      p "******************************************************"
      
      
      st_date.upto(ed_date) {|end_date|


        table_name = "log_call_#{end_date.strftime('%Y')}_#{end_date.strftime('%m')}"    
        if  !ActiveRecord::Base.connection.tables.include?(table_name)
          ActiveRecord::Schema.define(:version => 20140203143328) do
            create_table "#{table_name}", :force => true do |t|
              t.date     "date_start"
              t.integer  "listener_id"
              t.integer  "gateway_id"
              t.integer  "entryway_id"
             # t.integer  "seconds"
             # t.integer  "ani_e164"
            end
          end
          index_sql = "CREATE INDEX date_start ON #{table_name}(date_start)"
          ActiveRecord::Base.connection.execute(index_sql)
        end
        
        p "------------------------------"
        p "Processing date : #{end_date}"
        p "------------------------------"
        #p sql ="insert into #{table_name} (date_start,listener_id,gateway_id,entryway_id,seconds,ani_e164)  
         #     select date_start,listener_id,gateway_id,entryway_id,seconds,ani_e164 from log_call where date(date_start) = '#{end_date.strftime('%Y-%m-%d')}';"
        p sql ="INSERT into #{table_name} (date_start,listener_id,gateway_id,entryway_id)  
              SELECT date_start,listener_id,gateway_id,entryway_id from log_call 
              WHERE date_start >= '#{end_date.strftime('%Y-%m-%d 00:00:00')}' AND date_start <= '#{end_date.strftime('%Y-%m-%d 23:59:59')}'"
        ActiveRecord::Base.connection.execute(sql)
   
      }
    end
  end
end