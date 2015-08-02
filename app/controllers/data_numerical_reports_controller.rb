class DataNumericalReportsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_user, except: [:daily_clec_minutes]
  
  # get rca minutes for data numerical reports
  def rca_minutes
    get_minutes("rca")
    if params[:rca_id].present?
      x = Report.weekly_minutes(params[:rca_id], "rca")
      @weekly_labels = x.collect{|x| x.first }
      @weekly_values = x.collect{|x| x.last }

      x = Report.current_week_minutes(params[:rca_id], "rca")
      @compare_labels = x.collect{|x| x.first }
      @compare_current_value = x.collect{|x| x.last }
      
      x = Report.last_week_minutes(params[:rca_id], "rca")
      @compare_prev_value = x.collect{|x| x.last }
    end
  end
  
  # get country minutes for data numerical reports
  def country_minutes    
    get_minutes("country")

    if params[:country_id].present?
      x = Report.weekly_minutes(params[:country_id], "country")
      @weekly_labels = x.collect{|x| x.first }
      @weekly_values = x.collect{|x| x.last }

      x = Report.current_week_minutes(params[:country_id], "country")
      @compare_labels = x.collect{|x| x.first }
      @compare_current_value = x.collect{|x| x.last }
      
      x = Report.last_week_minutes(params[:country_id], "country")
      @compare_prev_value = x.collect{|x| x.last }
    end
  end
  
  def get_minutes(type)

    get_minutes_graphs_by_day(type,params["#{type}_id"]) if params["#{type}_id"].present?
    get_minutes_graphs_by_week(type,params["#{type}_id"]) if params["#{type}_id"].present?
    result = []
    @result_mini = params["#{type}_id"].present? ? get_top_3_stations("#{type}_id",params["#{type}_id"]) : []
    sort = params[:sort]
    sort_field = params[:sort_field]
    current_page =  params[:page].present? ? params[:page] : 1

    @result = []
    if (DateTime.now - 1.day).strftime("%m") >= "01" && (DateTime.now - 1.day).strftime("%m") < "07"
      table_name_new = "report_#{DateTime.now.strftime('%Y')}_1"
      table_name_old = "report_#{(DateTime.now - 6.months).strftime('%Y')}_2"
    else
      table_name_new = "report_#{DateTime.now.strftime('%Y')}_2"
      table_name_old = "report_#{(DateTime.now - 6.months).strftime('%Y')}_1"
    end
    if type == "rca"
      inner_join = " INNER JOIN  data_group_rca as dgc on dgc.id = dg.rca_id"
    else
      inner_join = " INNER JOIN  data_group_country as dgc on dgc.id = dg.country_id"
    end

    five_weeks_sql = "SELECT GROUP_CONCAT(res.report_week order by res.report_week ASC), GROUP_CONCAT(total_minutes order by res.report_week ASC),res.title,res.id,count(total_minutes) as total FROM
                        ( SELECT WEEK(report.report_date,6) as report_week, sum(total_minutes) as total_minutes,dgc.title,dgc.id FROM #{table_name_new} as report 
                         INNER JOIN data_gateway as dg on dg.id = report.gateway_id 
                          #{inner_join}
                          WHERE report_date >= CURDATE() - INTERVAL 5 WEEK and dgc.title IS NOT NULL and dgc.is_deleted = false and dg.is_deleted = false
                          GROUP BY dgc.id,report_week HAVING total_minutes > 1000 
                         UNION ALL
                         SELECT WEEK(report.report_date,6) as report_week, sum(total_minutes) as total_minutes,dgc.title,dgc.id FROM #{table_name_old} as report 
                         INNER JOIN data_gateway as dg on dg.id = report.gateway_id 
                          #{inner_join}
                          WHERE report_date >= CURDATE() - INTERVAL 5 WEEK and dgc.title IS NOT NULL and dgc.is_deleted = false and dg.is_deleted = false
                          GROUP BY dgc.id,report_week HAVING total_minutes > 1000 ) as res 
                        GROUP BY res.id"
   
    last_week_sql = "SELECT results.minutes, results.title,results.id FROM (SELECT sum(total_minutes) as minutes,dgc.title as title ,dgc.id as id FROM #{table_name_new} as report
                         INNER JOIN data_gateway as dg on dg.id = report.gateway_id 
                         #{inner_join}
                          WHERE report_date >= '#{1.week.ago.at_beginning_of_week(:sunday).strftime("%Y-%m-%d")}' 
                                and report_date < '#{(DateTime.now - 1.week).strftime("%Y-%m-%d")}'  and dgc.title IS NOT NULL and dgc.is_deleted = false and dg.is_deleted = false
                         GROUP BY dgc.id
                     UNION ALL
                     SELECT sum(total_minutes) as minutes,dgc.title as title,dgc.id as id FROM #{table_name_old} as report
                         INNER JOIN data_gateway as dg on dg.id = report.gateway_id 
                         #{inner_join}
                          WHERE report_date >= '#{1.week.ago.at_beginning_of_week(:sunday).strftime("%Y-%m-%d")}' 
                                and report_date < '#{(DateTime.now - 1.week).strftime("%Y-%m-%d")}'  and dgc.title IS NOT NULL and dgc.is_deleted = false and dg.is_deleted = false
                         GROUP BY dgc.id) as results group by results.title,results.id "
    
    current_week_sql = "SELECT results.minutes, results.title,results.id FROM (SELECT sum(total_minutes) as minutes,dgc.title as title,dgc.id as id FROM #{table_name_new} as report
                         INNER JOIN data_gateway as dg on dg.id = report.gateway_id 
                         #{inner_join}
                        WHERE report_date >= '#{0.week.ago.at_beginning_of_week(:sunday).strftime("%Y-%m-%d")}' and report_date <= '#{DateTime.now.strftime("%Y-%m-%d")}' and dgc.title IS NOT NULL
                         AND dgc.is_deleted = false and dg.is_deleted = false  GROUP BY dgc.id
                      UNION ALL
                      SELECT sum(total_minutes) as minutes ,dgc.title as title,dgc.id as id FROM #{table_name_old} as report
                                           INNER JOIN data_gateway as dg on dg.id = report.gateway_id 
                                           #{inner_join}
                                          WHERE report_date >= '#{0.week.ago.at_beginning_of_week(:sunday).strftime("%Y-%m-%d")}' and report_date <= '#{DateTime.now.strftime("%Y-%m-%d")}' and dgc.title IS NOT NULL
                                           AND dgc.is_deleted = false and dg.is_deleted = false  GROUP BY dgc.id) as results group by results.title,results.id"
       
    last_weeks_data =ActiveRecord::Base.connection.execute(five_weeks_sql).to_a
    current_week_data =ActiveRecord::Base.connection.execute(current_week_sql).to_a 
    if type=="country" && (params["type"] == "minutes" || params["type"] == "percentage" || !params["type"].present?)
      @page_no = Kaminari.paginate_array([], total_count: last_weeks_data.length).page(params[:page]).per(20) 
    end
    
    if params["type"] == "minutes"
      current_to_last_week_data = ActiveRecord::Base.connection.execute(last_week_sql).to_a
      last_weeks_data.each do |last|
        current = [] 
        current = current_week_data.detect {|curr| curr[2] == last[3] } if current_week_data[0].present?
        
        current_to_last_week = current_to_last_week_data.detect {|curr| curr[2] == last[3] } if current_to_last_week_data[0].present?
        
        results = last[1].split(',')
        no_of_current_week = DateTime.now.cweek
        weeks_no_res = last[0].split(',')

        if results.length < 5
          ((no_of_current_week-5)..no_of_current_week ).each_with_index do |w,index|
            if weeks_no_res[index].to_i != w.to_i
              weeks_no_res.insert(index,0)
              results.insert(index,"0")
            end
          end
        end
        
        four_weeks = results.present? && results[1].present? ? results[1] : 0
        three_weeks = results.present?&& results[2].present? ? results[2] : 0
        two_weeks = results.present? && results[3].present? ? results[3] : 0
        one_week = results.present? && results[4].present? ? results[4] : 0
        last_week = current_to_last_week.present? && current_to_last_week[0].present? ? current_to_last_week[0] : 0
        current_week = current.present? && current[0].present? ? current[0] : 0
        title = last[2]
        id = last[3]
        @result_mini << [title, id,one_week, current_week] if !params["#{type}_id"].present?
        result << [title, id, four_weeks, three_weeks, two_weeks, one_week, current_week,last_week]
      end
      result = sort_countries(result,sort,sort_field)
    elsif params[:type] == "percentage" || !params[:type].present?    
      current_to_last_week_data = ActiveRecord::Base.connection.execute(last_week_sql).to_a
      last_weeks_data.each do |last|
        current = [] 
        current = current_week_data.detect {|curr| curr[2] == last[3] } if current_week_data[0].present?
        current_to_last_week = []
        current_to_last_week = current_to_last_week_data.detect {|curr| curr[2] == last[3] } if current_to_last_week_data[0].present?
        
        results = last[1].split(',')
        no_of_current_week = DateTime.now.cweek
        weeks_no_res = last[0].split(',')
        
        if results.length < 5
          ((no_of_current_week-5)..no_of_current_week ).each_with_index do |w,index|
            if weeks_no_res[index].to_i != w.to_i 
              weeks_no_res.insert(index,0)
              results.insert(index,0)
            end
          end
        end
        
        four_weeks = results.present? && results[1].present? ? results[1] : 0
        three_weeks = results.present? && results[2].present? ? results[2] : 0
        two_weeks = results.present? && results[3].present? ? results[3] : 0
        one_week = results.present? && results[4].present? ? results[4] : 0
        last_week = current_to_last_week.present? && current_to_last_week[0].present? ? current_to_last_week[0] : 0
        current_week = current.present? && current[0].present? ? current[0] : 0
        
        
        third_val,second_val,first_val,compare_current_val = 0,0,0,0

        if  four_weeks.to_i != 0 && three_weeks.to_i != 0
          third_val = (100-((three_weeks.to_i * 100)/four_weeks.to_i))
        end
          
        if  three_weeks.to_i != 0 && two_weeks.to_i != 0
          second_val = (100-((two_weeks.to_i * 100)/three_weeks.to_i))
        end
          
        if two_weeks.to_i != 0 && one_week.to_i != 0
          first_val = (100-((one_week.to_i * 100)/two_weeks.to_i))
        end
          
        if  last_week.present? && last_week != 0 && current_week.present? && current_week != 0
          compare_current_val = (100-((current_week.to_i * 100)/last_week.to_i))
        end
        title = last[2]
        id = last[3] 
        @result_mini << [title, id, first_val, compare_current_val] if !params["#{type}_id"].present?
        result << [title, id,third_val, second_val, first_val, compare_current_val]
        result = sort_countries(result,sort,sort_field)
        
      end
    elsif params[:type] == "users"
      result = get_country_users
      @page_no = Kaminari.paginate_array([], total_count: result.length).page(params[:page]).per(20)
    end
    if type == "country"
      result = sort_countries(result,sort,sort_field)
      from_index = (current_page.to_i - 1) * 20
      until_index = ((current_page.to_i - 1) * 20)+19
      @result_mini = @result_mini.sort{|a, b| a[3].to_i <=> b[3].to_i}
      @result = result[from_index..until_index].to_a
    else
      @result = result
      @result_mini = @result_mini.sort{|a, b| a[3].to_i <=> b[3].to_i}
    end
  end
  
  def get_minutes_graphs_by_week(type,id)
    
    if type == "rca"
      rca = DataGroupRca.find(id)
      ids = rca.data_gateways.map(&:id)
    else
      country = DataGroupCountry.find(id)
      ids = country.data_gateways.map(&:id)
    end  
    if (DateTime.now - 1.day).strftime("%m") >= "01" && (DateTime.now - 1.day).strftime("%m") < "07"
      table_name_new = "report_#{DateTime.now.strftime('%Y')}_1"
      table_name_old = "report_#{(DateTime.now - 6.months).strftime('%Y')}_2"
    else
      table_name_new = "report_#{DateTime.now.strftime('%Y')}_2"
      table_name_old = "report_#{(DateTime.now - 6.months).strftime('%Y')}_1"
    end
    sql_1_week = "SELECT sum(total_minutes),report_date FROM #{table_name_new} 
                    WHERE report_date >= '#{1.week.ago.at_beginning_of_week(:sunday).strftime("%Y-%m-%d")}' and report_date <= '#{1.week.ago.end_of_week(:sunday).strftime("%Y-%m-%d")}' 
                          and gateway_id IN (#{ids.join(',')}) group by report_date
                  UNION ALL
                      SELECT sum(total_minutes),report_date FROM #{table_name_old} 
                    WHERE report_date >= '#{1.week.ago.at_beginning_of_week(:sunday).strftime("%Y-%m-%d")}' and report_date <= '#{1.week.ago.end_of_week(:sunday).strftime("%Y-%m-%d")}' 
                          and gateway_id IN (#{ids.join(',')}) group by report_date"
    sql_current_week = "SELECT sum(total_minutes),report_date FROM #{table_name_new} 
                            WHERE report_date >= '#{0.week.ago.at_beginning_of_week(:sunday).strftime("%Y-%m-%d")}' and report_date < '#{DateTime.now.strftime("%Y-%m-%d")}' 
                                  and gateway_id IN (#{ids.join(',')}) group by report_date
                          UNION ALL
                    SELECT sum(total_minutes),report_date FROM #{table_name_old} 
                            WHERE report_date >= '#{0.week.ago.at_beginning_of_week(:sunday).strftime("%Y-%m-%d")}' and report_date < '#{DateTime.now.strftime("%Y-%m-%d")}' 
                                  and gateway_id IN (#{ids.join(',')}) group by report_date"
    
   
    one_week = ActiveRecord::Base.connection.execute(sql_1_week).to_a
    current_week = ActiveRecord::Base.connection.execute(sql_current_week).to_a  
   
    data_table = GoogleVisualr::DataTable.new

    data_table.new_column('string', 'Day')
    data_table.new_column('number', 'Last Week')
    data_table.new_column('number', 'Current Week')
    
    last_week_result =[]
    one_week.each do |first|
      last_week_result << first[0]
    end
    current_week_result =[]
    current_week.each do |curr|
      current_week_result << curr[0]
    end
    date = Date.today
    days_of_week = (date.at_beginning_of_week(:sunday)..date.at_end_of_week(:sunday)).to_a
    rows = []
    days_of_week.each_with_index do |day,index|
      rows << [day.strftime("%a"),last_week_result[index],current_week_result[index].present? ? current_week_result[index] : 0 ]
    end
    data_table.add_rows(rows)
    opts = { width: 640,
      height: 250,
      title: "Last week and Current week  Minutes",
      :titleTextStyle => {color: '#11515E', fontSize: '14', bold: true},
      colors: ["#AE94D1","#038021"],
      :chartArea => {:left => 50, :top => 40, :width => 640},
      areaOpacity: 1.0, hAxis: {slantedTextAngle: 45, slantedText: true}}
    @week_graphs = GoogleVisualr::Interactive::LineChart.new(data_table, opts)
  end
  
  def get_minutes_graphs_by_day(type,id)
    if type == "rca"
      rca = DataGroupRca.find(id)
      ids = rca.data_gateways.map(&:id)
    else
      country = DataGroupCountry.find(id)
      ids = country.data_gateways.map(&:id)
    end  
    
    if (DateTime.now - 1.day).strftime("%m") >= "01" && (DateTime.now - 1.day).strftime("%m") < "07"
      table_name_new = "report_#{DateTime.now.strftime('%Y')}_1"
      table_name_old = "report_#{(DateTime.now - 6.months).strftime('%Y')}_2"
    else
      table_name_new = "report_#{DateTime.now.strftime('%Y')}_2"
      table_name_old = "report_#{(DateTime.now - 6.months).strftime('%Y')}_1"
    end
    
    sql_4_week = "SELECT sum(result.total_sum) FROM 
                    (SELECT sum(total_minutes) as total_sum FROM #{table_name_new} 
                    WHERE report_date = '#{((DateTime.now-1.day)-4.week).strftime("%Y-%m-%d")}' 
                          and gateway_id IN (#{ids.join(',')}) 
                  UNION ALL
                  SELECT sum(total_minutes) as total_sum FROM #{table_name_old} 
                    WHERE report_date = '#{((DateTime.now-1.day)-4.week).strftime("%Y-%m-%d")}' 
                          and gateway_id IN (#{ids.join(',')})) as result"
    
    sql_3_week = "SELECT sum(result.total_sum) FROM 
                  (SELECT sum(total_minutes) as total_sum FROM #{table_name_new} 
                    WHERE  report_date = '#{((DateTime.now-1.day)-3.week).strftime("%Y-%m-%d")}'
                          and gateway_id IN (#{ids.join(',')})  
                  UNION ALL
                  SELECT sum(total_minutes) as total_sum FROM #{table_name_old} 
                    WHERE  report_date = '#{((DateTime.now-1.day)-3.week).strftime("%Y-%m-%d")}'
                          and gateway_id IN (#{ids.join(',')})) as result"
    
    sql_2_week = "SELECT sum(result.total_sum) FROM 
                  (SELECT sum(total_minutes) as total_sum FROM #{table_name_new} 
                    WHERE  report_date = '#{((DateTime.now-1.day)-2.week).strftime("%Y-%m-%d")}'
                          and gateway_id IN (#{ids.join(',')}) 
                  UNION ALL 
                  SELECT sum(total_minutes) as total_sum FROM #{table_name_old} 
                    WHERE  report_date = '#{((DateTime.now-1.day)-2.week).strftime("%Y-%m-%d")}'
                          and gateway_id IN (#{ids.join(',')})) as result"
    
    sql_1_week = "SELECT sum(result.total_sum) FROM 
                  (SELECT sum(total_minutes) as total_sum FROM #{table_name_new} 
                    WHERE  report_date = '#{((DateTime.now-1.day)-1.week).strftime("%Y-%m-%d")}'
                          and gateway_id IN (#{ids.join(',')}) 
                   UNION ALL
                  SELECT sum(total_minutes) as total_sum FROM #{table_name_old} 
                    WHERE  report_date = '#{((DateTime.now-1.day)-1.week).strftime("%Y-%m-%d")}'
                          and gateway_id IN (#{ids.join(',')})) as result "
                   
    sql_current_week = "SELECT sum(result.total_sum) FROM 
                        (SELECT sum(total_minutes) as total_sum FROM #{table_name_new} 
                            WHERE  report_date = '#{(DateTime.now-1.day).strftime("%Y-%m-%d")}'
                                  and gateway_id IN (#{ids.join(',')}) 
                          UNION ALL
                        SELECT sum(total_minutes) as total_sum FROM #{table_name_old} 
                            WHERE  report_date = '#{(DateTime.now-1.day).strftime("%Y-%m-%d")}'
                                  and gateway_id IN (#{ids.join(',')})) as result"
    
    four_weeks = ActiveRecord::Base.connection.execute(sql_4_week).to_a
    three_weeks = ActiveRecord::Base.connection.execute(sql_3_week).to_a
    two_weeks = ActiveRecord::Base.connection.execute(sql_2_week).to_a
    one_week = ActiveRecord::Base.connection.execute(sql_1_week).to_a
    current_week = ActiveRecord::Base.connection.execute(sql_current_week).to_a   

    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Day')
    data_table.new_column('number', 'Minutes')
    rows = []
    rows << [((DateTime.now-1.day)-4.week).strftime("%a %e") ,four_weeks[0][0]]
    rows << [((DateTime.now-1.day)-3.week).strftime("%a %e") ,three_weeks[0][0]]
    rows << [((DateTime.now-1.day)-2.week).strftime("%a %e") ,two_weeks[0][0]]
    rows << [((DateTime.now-1.day)-1.week).strftime("%a %e") ,one_week[0][0]]
    rows << [(DateTime.now-1.day).strftime("%a %e") ,current_week[0][0]]
    data_table.add_rows(rows)
    opts = { width: 280,
      height: 250,
      title: "#{(DateTime.now-1.day).strftime('%A')}'s Minutes",
      :titleTextStyle => {color: '#11515E', fontSize: '14', bold: true},
      colors: ["#AE94D1"],
      :chartArea => {:left => 50, :top => 40, :width => 300},
      areaOpacity: 1.0, hAxis: {slantedTextAngle: 45, slantedText: true}}
    @day_graphs = GoogleVisualr::Interactive::LineChart.new(data_table, opts)
  end
    
  def get_top_3_stations(type,id)
    
    result = []
    if (DateTime.now - 1.day).strftime("%m") >= "01" && (DateTime.now - 1.day).strftime("%m") < "07"
      table_name_new = "report_#{DateTime.now.strftime('%Y')}_1"
      table_name_old = "report_#{(DateTime.now - 6.months).strftime('%Y')}_2"
    else
      table_name_new = "report_#{DateTime.now.strftime('%Y')}_2"
      table_name_old = "report_#{(DateTime.now - 6.months).strftime('%Y')}_1"
    end
    where = "AND dg.#{type} = #{id}"
  
    five_weeks_sql = "SELECT GROUP_CONCAT(res.report_week order by res.report_week ASC), GROUP_CONCAT(total_minutes order by res.report_week ASC),res.title,res.id,count(total_minutes) as total FROM
                        ( SELECT WEEK(report.report_date,6) as report_week, sum(total_minutes) as total_minutes,dg.title,dg.id FROM #{table_name_new} as report 
                         INNER JOIN data_gateway as dg on dg.id = report.gateway_id 
                          WHERE report_date >= CURDATE() - INTERVAL 5 WEEK and dg.title IS NOT NULL and dg.is_deleted = false
                          #{where}
                          GROUP BY dg.id,report_week HAVING total_minutes > 1000 
                        UNION ALL
                        SELECT WEEK(report.report_date,6) as report_week, sum(total_minutes) as total_minutes,dg.title,dg.id FROM #{table_name_old} as report 
                         INNER JOIN data_gateway as dg on dg.id = report.gateway_id 
                          WHERE report_date >= CURDATE() - INTERVAL 5 WEEK and dg.title IS NOT NULL and dg.is_deleted = false
                          #{where}
                          GROUP BY dg.id,report_week HAVING total_minutes > 1000 ) as res 
                        GROUP BY res.id HAVING total >= 5"
    
    last_week_sql = "SELECT results.minutes, results.title,results.id FROM (SELECT sum(total_minutes) as minutes,dg.title as title,dg.id as id FROM #{table_name_new} as report
                         INNER JOIN data_gateway as dg on dg.id = report.gateway_id 
                          WHERE report_date >= '#{1.week.ago.at_beginning_of_week(:sunday).strftime("%Y-%m-%d")}' 
                                and report_date < '#{(DateTime.now - 1.week).strftime("%Y-%m-%d")}' 
                                and dg.title IS NOT NULL and dg.is_deleted = false
                         #{where}
                          GROUP BY dg.id
                          UNION ALL
                      SELECT sum(total_minutes) as minutes,dg.title as title,dg.id as id FROM #{table_name_old} as report
                         INNER JOIN data_gateway as dg on dg.id = report.gateway_id 
                          WHERE report_date >= '#{1.week.ago.at_beginning_of_week(:sunday).strftime("%Y-%m-%d")}' 
                                and report_date < '#{(DateTime.now - 1.week).strftime("%Y-%m-%d")}' 
                                and dg.title IS NOT NULL and dg.is_deleted = false
                         #{where}
                          GROUP BY dg.id) as results"
    
    current_week_sql = "SELECT results.minutes, results.title,results.id FROM (SELECT sum(total_minutes) as minutes,dg.title as title,dg.id as id FROM #{table_name_new} as report
                         INNER JOIN data_gateway as dg on dg.id = report.gateway_id 
                        WHERE report_date >= '#{0.week.ago.at_beginning_of_week(:sunday).strftime("%Y-%m-%d")}' and report_date <= '#{DateTime.now.strftime("%Y-%m-%d")}' 
                      and dg.title IS NOT NULL and dg.is_deleted = false
                       #{where}
                          GROUP BY dg.id
                       UNION ALL
                      SELECT sum(total_minutes) as minutes,dg.title as title,dg.id as id FROM #{table_name_old} as report
                         INNER JOIN data_gateway as dg on dg.id = report.gateway_id 
                        WHERE report_date >= '#{0.week.ago.at_beginning_of_week(:sunday).strftime("%Y-%m-%d")}' and report_date <= '#{DateTime.now.strftime("%Y-%m-%d")}' 
                      and dg.title IS NOT NULL and dg.is_deleted = false
                       #{where}
                          GROUP BY dg.id) as results"
    
    
    
    last_weeks_data =ActiveRecord::Base.connection.execute(five_weeks_sql).to_a
    current_week_data =ActiveRecord::Base.connection.execute(current_week_sql).to_a 

    if params["type"] == "minutes" || params["type"] == "users"
      last_weeks_data.each do |last|
        current = [] 
        current = current_week_data.detect {|curr| curr[2] == last[3] } if current_week_data[0].present?
        results = last[1].split(',')
        no_of_current_week = DateTime.now.cweek
        weeks_no_res = last[0].split(',')
        
        if results.length < 5
          ((no_of_current_week-5)..no_of_current_week ).each_with_index do |w,index|
            if weeks_no_res[index].to_i != w.to_i 
              weeks_no_res.insert(index,0)
              results.insert(index,0)
            end
          end
        end
        one_week = results.present? && results[4].present? ? results[4] : 0
        current_week = current.present? && current[0].present? ? current[0] : 0
        title = last[2]
        id = last[3]
        result << [title, id, one_week.to_i, current_week.to_i]
      end
      
    else
      current_to_last_week_data = ActiveRecord::Base.connection.execute(last_week_sql).to_a
      last_weeks_data.each do |last|
        current = [] 
        current = current_week_data.detect {|curr| curr[2] == last[3] } if current_week_data[0].present?
        current_to_last_week = []
        current_to_last_week = current_to_last_week_data.detect {|curr| curr[2] == last[3] } if current_to_last_week_data[0].present?
        
        results = last[1].split(',')
        no_of_current_week = DateTime.now.cweek
        weeks_no_res = last[0].split(',')
        
        if results.length < 5
          ((no_of_current_week-5)..no_of_current_week ).each_with_index do |w,index|
            if weeks_no_res[index].to_i != w.to_i 
              weeks_no_res.insert(index,0)
              results.insert(index,0)
            end
          end
        end

        two_weeks = results.present? && results[3].present? ? results[3] : 0
        one_week = results.present? && results[4].present? ? results[4] : 0
        current_week = current.present? && current[0].present? ? current[0] : 0
        last_week = current_to_last_week.present? && current_to_last_week[0].present? ? current_to_last_week[0] : 0
        
        first_val,compare_current_val = 0,0
          
        if two_weeks != 0 && one_week != 0
          first_val = (100-((one_week.to_i * 100)/two_weeks.to_i))
        end
          
        if  last_week.present? && last_week != 0 && current_week.present? && current_week != 0
          compare_current_val = (100-((current_week.to_i * 100)/last_week.to_i))
        end
        title = last[2]
        id = last[3]       
        result << [title, id, first_val, compare_current_val]
      end
    end
    result
  end
  
  def sort_countries(data,sort = nil,sort_field = nil) 
    sort = "ASC" if sort== nil
    sort_field = "current_week" if sort_field == nil
    result = []
    # result << [title, id,third_val, second_val, first_val, compare_current_val]
    # result << [title, id, four_weeks, three_weeks, two_weeks, one_week, current_week]
    if data.present?
      if data[0].length == 6
        case sort_field
        when "country"
          param= 0
        when "three_weeks"
          param= 2
        when "two_weeks"
          param= 3
        when "one_week"
          param= 4
        when "current_week"
          param= 5
        else
          param= 5
        end
      elsif data[0].length == 7 || data[0].length == 8
        case sort_field
        when "country"
          param= 0
        when "four_weeks"
          param= 2
        when "three_weeks"
          param= 3
        when "two_weeks"
          param= 4
        when "one_week"
          param= 5
        when "current_week"
          param= 6
        else
          param= 6
        end
      end
      if data[0].present?
        if sort == "ASC"
          result = sort_field == "country" ? data.sort{|a, b| a[param] <=> b[param]} : data.sort{|a, b| a[param].to_i <=> b[param].to_i}
        elsif sort == "DESC"
          result = sort_field == "country" ? data.sort{|a, b| b[param] <=> a[param]} : data.sort{|a, b| b[param].to_i <=> a[param].to_i}
        else
          result = data.sort{|a, b| a[param].to_i <=> b[param].to_i}
        end
      end
    end
    result
  end
  
  def get_country_users
    
    result = []
    
    if (DateTime.now - 1.day).strftime("%m") >= "01" && (DateTime.now - 1.day).strftime("%m") < "07"
      table_name_new = "report_#{DateTime.now.strftime('%Y')}_1"
      table_name_old = "report_#{(DateTime.now - 6.months).strftime('%Y')}_2"
    else
      table_name_new = "report_#{DateTime.now.strftime('%Y')}_2"
      table_name_old = "report_#{(DateTime.now - 6.months).strftime('%Y')}_1"
    end
    
    sql = "SELECT GROUP_CONCAT(report.report_week order by report.report_week ASC) as weeks,
                  GROUP_CONCAT(total_listeners order by report.report_week ASC) as listeners,
                  report.title,
                  report.id,
                  count(total_listeners) as total 
          FROM
                  (SELECT WEEK(rep.report_date,6) as report_week, 
                          sum(rep.users_by_time) as total_listeners,
                          dgc.title,
                          dgc.id,
                          sum(total_minutes) as total_minutes from #{table_name_new} as rep
                  INNER JOIN data_gateway as dg on dg.id = rep.gateway_id 
                  INNER JOIN data_group_country as dgc on dgc.id = dg.country_id
                  WHERE dgc.is_deleted = false and dg.is_deleted = false and report_date >= CURDATE() - INTERVAL 5 WEEK and dgc.title IS NOT NULL
                  GROUP by dg.country_id,report_week HAVING total_minutes >1000
                  UNION ALL
                  SELECT WEEK(rep.report_date,6) as report_week, 
                          sum(rep.users_by_time) as total_listeners,
                          dgc.title,
                          dgc.id,
                          sum(total_minutes) as total_minutes from #{table_name_old} as rep
                  INNER JOIN data_gateway as dg on dg.id = rep.gateway_id 
                  INNER JOIN data_group_country as dgc on dgc.id = dg.country_id
                  WHERE dgc.is_deleted = false and dg.is_deleted = false and report_date >= CURDATE() - INTERVAL 5 WEEK and dgc.title IS NOT NULL
                  GROUP by dg.country_id,report_week HAVING total_minutes >1000) as report
         GROUP BY report.id having total >=5 "
    
    sql_current_week = "SELECT SUM(results.users),results.title,results.id FROM (SELECT sum(users_by_time) as users,dgc.title as title,dgc.id as id FROM #{table_name_new} as report
                         INNER JOIN data_gateway as dg on dg.id = report.gateway_id 
                         INNER JOIN  data_group_country as dgc on dgc.id = dg.country_id
                        WHERE report_date >= '#{0.week.ago.at_beginning_of_week(:sunday).strftime("%Y-%m-%d")}' and report_date <= '#{DateTime.now.strftime("%Y-%m-%d")}' and dgc.title IS NOT NULL
                       and dgc.is_deleted = false and dg.is_deleted = false  GROUP BY dgc.id
                        UNION ALL 
                        SELECT sum(users_by_time) as users,dgc.title as title,dgc.id as id FROM #{table_name_old} as report
                         INNER JOIN data_gateway as dg on dg.id = report.gateway_id 
                         INNER JOIN  data_group_country as dgc on dgc.id = dg.country_id
                        WHERE report_date >= '#{0.week.ago.at_beginning_of_week(:sunday).strftime("%Y-%m-%d")}' and report_date <= '#{DateTime.now.strftime("%Y-%m-%d")}' and dgc.title IS NOT NULL
                       and dgc.is_deleted = false and dg.is_deleted = false  GROUP BY dgc.id) as results group by results.title,results.id"
    
    data_result = ActiveRecord::Base.connection.execute(sql).to_a
    current_week_data = ActiveRecord::Base.connection.execute(sql_current_week).to_a
    data_result.each do |last|
      current = [] 
      current = current_week_data.detect {|curr| curr[2] == last[3] } if current_week_data[0].present?
      results = last[1].split(',')
      no_of_current_week = DateTime.now.cweek
      weeks_no_res = last[0].split(',')
        
      if results.length < 5
        ((no_of_current_week-5)..no_of_current_week ).each_with_index do |w,index|
          if weeks_no_res[index].to_i != w.to_i 
            weeks_no_res.insert(index,0)
            results.insert(index,0)
          end
        end
      end
        
      four_weeks = results.present? && results[0].present? ? results[0] : 0
      three_weeks = results.present? && results[1].present? ? results[1] : 0
      two_weeks = results.present? && results[2].present? ? results[2] : 0
      one_week = results.present? && results[3].present? ? results[3] : 0
      current_week = current.present? && current[0].present? ? current[0] : 0
      title = last[2]
      id = last[3]
      @result_mini << [title, id, one_week, current_week] if !params[:country_id].present?
      result << [title, id, four_weeks, three_weeks, two_weeks, one_week, current_week]
    end
    result
  end

  def daily_clec_minutes
    params[:page] ||= 1
    params[:per] ||= 10
    dt = Time.now.in_time_zone('Eastern Time (US & Canada)')
    results = {}
    periods = {today: dt.strftime("%Y-%m-%d"),
              yesterday: (dt - 1.day).strftime("%Y-%m-%d"),
              last_two_days: (dt - 2.days).strftime("%Y-%m-%d"),
              last_seven_days: (dt - 7.days).strftime("%Y-%m-%d"),
              last_fourteen_days: (dt - 14.days).strftime("%Y-%m-%d")}
    periods.each do |k, v|
      results[k] = ActiveRecord::Base.connection.execute(create_clec_query(period=v)).to_a
    end
    providers = corelate_result_to_clec(results, query=params[:query])
    @providers = Kaminari.paginate_array(providers).page(params[:page]).per(params[:per])
    # render json: providers
  end

  def weekly_clec_minutes
    params[:page] ||= 1
    params[:per] ||= 10
    dt = Time.now.in_time_zone('Eastern Time (US & Canada)')
    results = {}
    week = [dt.strftime("%Y-%m-%d"), (dt - 7.days).strftime("%Y-%m-%d")]
    week2 = [week[1], (Date.strptime(week[1], "%Y-%m-%d") - 7.days).strftime("%Y-%m-%d")]
    week3 = [week2[1], (Date.strptime(week2[1], "%Y-%m-%d") - 7.days).strftime("%Y-%m-%d")]
    week4 = [week3[1], (Date.strptime(week3[1], "%Y-%m-%d") - 7.days).strftime("%Y-%m-%d")]
    periods = {week: week,
               week2: week2,
               week3: week3,
               week4: week4}
    @labels = []
    periods.each do |k, v|
      @labels.push("#{v[0].to_time.strftime('%b %d, %y')} - #{v[1].to_time.strftime('%b %d, %y')}")
      results[k] = ActiveRecord::Base.connection.execute(create_clec_query_by_duration(period=v)).to_a
    end
    providers = corelate_result_to_clec(results, query=params[:query])
    @providers = Kaminari.paginate_array(providers).page(params[:page]).per(params[:per])
    # render json: @labels
  end

  def monthly_clec_minutes
    params[:page] ||= 1
    params[:per] ||= 10
    dt = Time.now.in_time_zone('Eastern Time (US & Canada)')
    results = {}
    month = [dt.at_end_of_month.strftime("%Y-%m-%d"),
             dt.at_beginning_of_month.strftime("%Y-%m-%d")]
    month2 = [(Date.strptime(month[0], "%Y-%m-%d") - 1.month).at_end_of_month.strftime("%Y-%m-%d"),
              (Date.strptime(month[0], "%Y-%m-%d") - 1.month).at_beginning_of_month.strftime("%Y-%m-%d")]
    month3 = [(Date.strptime(month2[0], "%Y-%m-%d") - 1.month).at_end_of_month.strftime("%Y-%m-%d"),
              (Date.strptime(month2[0], "%Y-%m-%d") - 1.month).at_beginning_of_month.strftime("%Y-%m-%d")]
    month4 = [(Date.strptime(month3[0], "%Y-%m-%d") - 1.month).at_end_of_month.strftime("%Y-%m-%d"),
              (Date.strptime(month3[0], "%Y-%m-%d") - 1.month).at_beginning_of_month.strftime("%Y-%m-%d")]
    # month5 = [(Date.strptime(month4[0], "%Y-%m-%d") - 1.month).at_end_of_month.strftime("%Y-%m-%d"),
    #           (Date.strptime(month4[0], "%Y-%m-%d") - 1.month).at_beginning_of_month.strftime("%Y-%m-%d")]
    # month6 = [(Date.strptime(month5[0], "%Y-%m-%d") - 1.month).at_end_of_month.strftime("%Y-%m-%d"),
    #           (Date.strptime(month5[0], "%Y-%m-%d") - 1.month).at_beginning_of_month.strftime("%Y-%m-%d")]
    periods = {month: month,
               month2: month2,
               month3: month3,
               month4: month4}
    @labels = []
    periods.each do |k, v|
      @labels.push("#{v[1].to_time.strftime('%b %Y')}")
      results[k] = ActiveRecord::Base.connection.execute(create_clec_large_query_by_duration(period=v)).to_a
    end
    providers = corelate_result_to_clec(results, query=params[:query])
    @providers = Kaminari.paginate_array(providers).page(params[:page]).per(params[:per])
    # render json: @labels
  end

  protected
  def validate_user
    if current_user.is_rca? || current_user.is_broadcaster?
      redirect_to root_path
    end
  end

  private
  def create_clec_large_query_by_duration(period=[])
    unless period.empty?
      where = " ("
      startdate = Date.strptime(period[1], "%Y-%m-%d")
      enddate = Date.strptime(period[0], "%Y-%m-%d")
      daysrange = (startdate.day..enddate.day)
      daysrange.each do |d|
        if d == enddate.day
          where += " date = '#{startdate.year}-#{startdate.month}-#{d}' "
        else
          where += " date = '#{startdate.year}-#{startdate.month}-#{d}' OR "
        end
      end
      where += ") "
      where += " and entryway_provider is not null "
      if marketer?
        sql = " SELECT DATE(date), gateway_id, COUNT(entryway_id), entryway_provider, (sum(seconds)/60) FROM summary_call_15m WHERE #{where} GROUP by entryway_provider"
      elsif rca?
        gateway_ids = current_user.stations.map(&:id)
        sql = " SELECT DATE(date), gateway_id, COUNT(entryway_id), entryway_provider, (sum(seconds)/60) FROM summary_call_15m WHERE gateway_id IN (#{gateway_ids.join(',')}) and #{where} GROUP by entryway_provider"
      else
        return nil
      end
    end
  end

  def create_clec_query_by_duration(period=[])
    unless period.empty?
      where = " entryway_provider is not null "
      if marketer?
        sql = " SELECT DATE(date), gateway_id, COUNT(entryway_id), entryway_provider, (sum(seconds)/60) FROM summary_call_15m WHERE #{where} and (date >= '#{period[1]}' and date <= '#{period[0]}') GROUP by entryway_provider"
      elsif rca?
        gateway_ids = current_user.stations.map(&:id)
        sql = " SELECT DATE(date), gateway_id, COUNT(entryway_id), entryway_provider, (sum(seconds)/60) FROM summary_call_15m WHERE #{where} and gateway_id IN (#{gateway_ids.join(',')}) and (date >= '#{period[1]}' and date <= '#{period[0]}') GROUP by entryway_provider"
      else
        return nil
      end
    end
  end

  def create_clec_query(period=nil)
    if marketer?
      sql = " SELECT DATE(date), gateway_id, COUNT(entryway_id), entryway_provider, (sum(seconds)/60) FROM summary_call_15m WHERE date = '#{period}' GROUP by entryway_provider"
    elsif rca?
      gateway_ids = current_user.stations.map(&:id)
      sql = " SELECT DATE(date), gateway_id, COUNT(entryway_id), entryway_provider, (sum(seconds)/60) FROM summary_call_15m WHERE gateway_id IN (#{gateway_ids.join(',')}) and date = '#{period}' GROUP by entryway_provider"
    else
      return nil
    end
  end

  def corelate_result_to_clec(rawresult, query=nil)
    if query.present?
      providers = DataEntrywayProvider.select([:id, :title]).where("TRIM(LOWER(title)) LIKE '%#{query.downcase.strip}%'").order('title ASC')
    else
      providers = DataEntrywayProvider.select([:id, :title]).order('title ASC')
    end
    results = []
    providers.each do |prov|
      result = {}
      localdata = {}
      rawresult.each do |k, values|
        data = []
        values.each do |v|
          data = v if v.include? prov.id.to_i
        end
        localdata[k] = data
      end
      result[:title] = prov.title
      result[:data] = localdata
      results.push(result)
    end
    return results
  end

end