class ExportLog < Struct.new(:from_date, :until_date)
  def perform   
    # Create new file called 'filename.txt' at a specified path.
    #my_file = File.new("/reports_log/filename.txt","w")
    
    start_date = Date.parse(from_date).strftime('%Y-%m')
    end_date = Date.parse(until_date).strftime('%Y-%m')
    
    #start_date.upto(end_date) {|date|
    # my_file.write date.to_s
    if  ActiveRecord::Base.connection.tables.include?("report_#{start_date}_#{end_date}")
      p "table exists"
    else
      ActiveRecord::Schema.define(:version => 20140203143328) do
        create_table "report_#{start_date}_#{end_date}", :force => true do |t|
          t.date     "report_date"
          t.integer  "report_hours"
          t.integer  "active_users"
          t.integer  "new_users"
          t.integer  "sessions"
          t.integer  "total_minutes"
          t.integer  "users_by_time"
          t.integer  "gateway_id"
          t.datetime "created_at",    :null => false
          t.datetime "updated_at",    :null => false
        end
        p "table created" + "report_#{start_date}_#{end_date}"
      end
    end
    #}
    
    # Close the file.
    #my_file.close
  end
end