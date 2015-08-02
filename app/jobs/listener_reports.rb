class ListenerReports < Struct.new(:param)
  def perform
    
    p "******************************************************"
    p "-----------------Listener Reports---------------------"
    p "******************************************************"
    
    p "START TIME :"
    p Time.now
    
    table_name_total = "report_listener_totals"
    table_name_by_gateway = "report_listener_by_gateway_id"
    
    if !ActiveRecord::Base.connection.tables.include?(table_name_total)
      ActiveRecord::Schema.define(:version => 20140203143328) do
        create_table "#{table_name_total}", :force => true do |t|
          t.integer     "sys_user_id"
          t.integer  "total_listeners"
          t.datetime "created_at",    :null => false
        end
      end
    else
      sql = "TRUNCATE TABLE `#{table_name_total}`"
      ActiveRecord::Base.connection.execute(sql)
    end
    if !ActiveRecord::Base.connection.tables.include?(table_name_by_gateway)
      ActiveRecord::Schema.define(:version => 20140203143328) do
        create_table "#{table_name_by_gateway}", :force => true do |t|
          t.integer     "gateway_id"
          t.integer  "total_listeners"
          t.datetime "created_at",    :null => false
        end
      end
    else
      sql = "TRUNCATE TABLE `#{table_name_by_gateway}`"
      ActiveRecord::Base.connection.execute(sql)
    end
    
    User.all.each do |user|
      if user.stations.present?
        stations = user.stations.map(&:id)
        if stations.present?
          sql = "INSERT INTO #{table_name_total}(sys_user_id,total_listeners,created_at)  SELECT '#{user.id}' as sys_user_id ,COUNT(distinct listener_id) as total_listeners 
               ,NOW() as created_at FROM `data_listener_at_gateway` WHERE context_at_id IN (#{stations.join(',')})"
          ActiveRecord::Base.connection.execute(sql)
        end
      end
    end
    
    sql = "INSERT INTO #{table_name_by_gateway}(gateway_id,total_listeners,created_at) SELECT context_at_id as gateway_id,count(distinct listener_id) as total_listeners 
           ,NOW() as created_at from `data_listener_at_gateway` group by context_at_id"
    ActiveRecord::Base.connection.execute(sql)
    
    p "END TIME :"
    p Time.now
    
    p "******************************************************"
    p "-----------------Listener Reports---------------------"
    p "******************************************************"
  end
end