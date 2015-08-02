class LogCallBuffer < Struct.new(:param)
  def perform
    p "******************************************************"
    p "----- LOG CALL BUFFER TABLE - ACTION - #{param}------"
    p "******************************************************"
    
    table_name = "log_call_buffer"
    #date = DateTime.now
    date = DateTime.parse("2014-02-05")
    # GETTING DATA FROM 90 days ago
    if param == "RESET"
      p sql = "TRUNCATE TABLE `#{table_name}`"
      ActiveRecord::Base.connection.execute(sql)
      90.downto 1 do |d|
        
        p "DAY #{d} - START at : #{DateTime.now.strftime("%H:%M:%S")}"
        
         sql = "INSERT INTO #{table_name}(date_start,date_stop,seconds,ani_e164,did_e164,listener_id,listener_ani_id,entryway_id,gateway_id)
              SELECT date_start,date_stop,seconds,ani_e164,did_e164,listener_id,listener_ani_id,entryway_id,gateway_id FROM log_call 
              WHERE date_start >= '#{(date - d.days).strftime("%Y-%m-%d")} 00:00:00 UTC' AND date_start) <= '#{(date - d.days).strftime("%Y-%m-%d")} 23:59:59 UTC'"
        ActiveRecord::Base.connection.execute(sql)
        
        p "END DAY #{d} - END at : #{DateTime.now.strftime("%H:%M:%S")}"
        
      end
      # GETTING DAILY DATA
    elsif param == "DAILY"
      check_last_insert_sql = "SELECT DATE(date_start) as last_date FROM log_call_buffer ORDER BY last_date DESC LIMIT 1"
      check_last_insert =ActiveRecord::Base.connection.execute(check_last_insert_sql).to_a
      
      p "DELETE OLD ROWS"
      p delete_old_rows = "DELETE FROM #{table_name} WHERE date_start > '#{(date - 90.days).strftime("%Y-%m-%d")} '"
      ActiveRecord::Base.connection.execute(delete_old_rows)
      p "END DELETE"
      
      if check_last_insert.present? && check_last_insert[0][0] == (date - 1.days).strftime("%Y-%m-%d")
        
        p "DAY #{date} - START at : #{DateTime.now.strftime("%H:%M:%S")}"
        
         sql = "INSERT INTO #{table_name}(date_start,date_stop,seconds,ani_e164,did_e164,listener_id,listener_ani_id,entryway_id,gateway_id)
              SELECT date_start,date_stop,seconds,ani_e164,did_e164,listener_id,listener_ani_id,entryway_id,gateway_id FROM log_call 
              WHERE date_start >= '#{(date - 1.days).strftime("%Y-%m-%d")} 00:00:00 UTC' AND date_start <= '#{(date - 1.days).strftime("%Y-%m-%d")} 23:59:59 UTC'"
        ActiveRecord::Base.connection.execute(sql)
        
        p "END DAY #{date} - END at : #{DateTime.now.strftime("%H:%M:%S")}"
        
      else
        start_date = DateTime.parse(check_last_insert[0][0].to_s).strftime("%d").to_i
        end_date = (DateTime.now -1.days).strftime("%d").to_i
        (start_date..end_date).each do |d|
          
          p "DAY #{d} - START at : #{DateTime.now.strftime("%H:%M:%S")}"
          
          sql = "INSERT INTO #{table_name}(date_start,date_stop,seconds,ani_e164,did_e164,listener_id,listener_ani_id,entryway_id,gateway_id)
              SELECT date_start,date_stop,seconds,ani_e164,did_e164,listener_id,listener_ani_id,entryway_id,gateway_id FROM log_call 
              WHERE date_start >= '#{(date - d.days).strftime("%Y-%m-%d")} 00:00:00 UTC' AND date_start <= '#{(date - d.days).strftime("%Y-%m-%d")} 23:59:59 UTC'"
          ActiveRecord::Base.connection.execute(sql)
          
          p "END DAY #{d} - END at : #{DateTime.now.strftime("%H:%M:%S")}"
          
        end
        
      end
    end
    p "******************************************************"
    p "----END LOG CALL BUFFER TABLE - ACTION - #{param}-----"
    p "******************************************************"
  end
end
