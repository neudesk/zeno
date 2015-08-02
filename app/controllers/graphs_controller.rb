  class GraphsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :js, :html
  def index
    @stations = []
    if current_user.stations.present?
      if current_user.stations.count == 1
        redirect_to "/graphs?station_id=#{current_user.stations}"
      end
      @stations = current_user.stations
      @q = @stations.search(params[:q])
      @stations = @q.result(distinct: true).page(params[:page]).per(15)
      if @stations.total_pages < params[:page].to_i
        params[:page] = 1
        @stations = @q.result(distinct: true).page(params[:page]).per(15)
      end
    end
    @page = params[:page] || 1
    @station = DataGateway.find_by_id(params[:station_id])
    if @station.present?
      result1 = Graph.generate_for("today", @station)
      result2 = Graph.generate_minutes("7days", @station)
    else
      result1 = current_user.stations.present? ? Graph.generate_for("today", current_user.stations) : []
      result2 = current_user.stations.present? ? Graph.generate_minutes("7days", current_user.stations) : []
    end
      @user_labels = result1.collect { |x| x.first }
      @user_values = result1.collect { |x| x.last }
      @minutes_labels = result2.collect { |x| x.first }
      @minutes_values = result2.collect { |x| x.last }
    # render :json => result1
  end

  def user_chart
    @station = DataGateway.find_by_id(params[:station_id])
    @station = current_user.stations unless @station.present?
    case params[:scope]
    when "Today"
      @result = Graph.generate_for("today", @station)
      @labels = @result.collect { |x| x.first }.join(",")
      @values = @result.collect { |x| x.last }.join(",")
    when "Yesterday"
      @result = Graph.generate_for("yesterday", @station)
      @labels = @result.collect { |x| x.first }.join(",")
      @values = @result.collect { |x| x.last }.join(",")
    when "7days"
      @result = Graph.generate_for("7days", @station)
      @labels = @result.collect { |x| x.first }.join(",")
      @values = @result.collect { |x| x.last }.join(",")
    when "30days"
      @result = Graph.generate_for("30days", @station)
      @labels = @result.collect { |x| x.first }.join(",")
      @values = @result.collect { |x| x.last }.join(",")
    when "90days"
      @result = Graph.generate_for("90days", @station)
      @labels = @result.collect { |x| x.first }.join(",")
      @values = @result.collect { |x| x.last }.join(",")
    end
  end

  def minutes_chart
    @station = DataGateway.find_by_id(params[:station_id])
    @station = current_user.stations unless @station.present?
    case params[:scope]
    when "7days"
      @result = Graph.generate_minutes("7days", @station)
      @labels = @result.collect { |x| x.first }.join(",")
      @values = @result.collect { |x| x.last }.join(",")
    when "30days"
      @result = Graph.generate_minutes("30days", @station)
      @labels = @result.collect { |x| x.first }.join(",")
      @values = @result.collect { |x| x.last }.join(",")
    when "90days"
      @result = Graph.generate_minutes("90days", @station)
      @labels = @result.collect { |x| x.first }.join(",")
      @values = @result.collect { |x| x.last }.join(",")
    end
  end

  def change_chart_c
    day = params[:day]
    object_id = (params[:object_id].to_i == 0)? nil : params[:object_id]
    entryway_id = object_id if current_user.is_thirdparty?
    gateway_id = object_id unless current_user.is_thirdparty?
    for_render_chart_c(day, gateway_id || nil, entryway_id || nil)
    render :partial => "charts/chart_c"
  end

  def for_render_chart_c(number, gateway_id, entryway_id = nil)
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Hour')

    data_table.new_column('number',"Users")

    #rows = LogCall.users_by_time(current_user, {day: number, gateway_id: gateway_id, entryway_id: entryway_id})
    rows =  get_user(number,gateway_id)

    if !rows.nil? && !current_user.is_thirdparty?
      data_table.add_rows(rows)
      opts = { :width => 460,
        :height => 250,
        :title => 'B. Users by time',
        :titleTextStyle => {color: '#11515E', fontSize: '14', bold: true},
        :chartArea => {:left => 50, :top => 40,:width => 300},
        hAxis: {slantedTextAngle: 45, slantedText: true}}
      @line_chart = GoogleVisualr::Interactive::LineChart.new(data_table, opts)
    end
  end

  def change_total_chart
    day = params[:day].to_i
    channel_id = (params[:channel_id].to_i == 0)? nil : params[:channel_id]
    gateway_id = (params[:gateway_id].to_i == 0)? nil : params[:gateway_id]
    gateway_id = current_user.stations[0].id if current_user.stations.length == 1
    for_render_total_chart(day, gateway_id, channel_id)
    render :partial => "charts/total_chart"
  end

  def for_render_total_chart(day, gateway_id = nil, channel_id = nil)
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Day')
    data_table.new_column('number', 'Minutes')
    rows = get_total_minutes(current_user, day, gateway_id, channel_id)
    data_table.add_rows(rows)
    opts = { width: 460,
      height: 250,
      title: 'C. Total Minutes',
      :titleTextStyle => {color: '#11515E', fontSize: '14', bold: true},
      colors: ["#AE94D1"],
      :chartArea => {:left => 50, :top => 40, :width => 320},
      areaOpacity: 1.0, hAxis: {slantedTextAngle: 45, slantedText: true}}
    @total_chart = GoogleVisualr::Interactive::AreaChart.new(data_table, opts)
  end

  def get_user(period,gateway_id = nil)
    results = []
    # IF DATE SELECTION IS "TODAY" OR "YESTARDAY" SELECT FROM "report_users_by_time"
    if period=="0" || period =="1"
      days= period.to_i.send("days").ago.strftime('%Y-%m-%d')
      if gateway_id
        sql = "SELECT report_hours,users_by_time FROM report_users_by_time where report_date = '#{days}' and gateway_id = '#{gateway_id}' "
      else
        if current_user.is_marketer?
          sql = "SELECT report_hours,users_by_time FROM report_users_by_time where report_date = '#{days}' and gateway_id = 0"
        else
          gateway_ids = current_user.stations.map(&:id)
          if gateway_ids.present?
            sql = "SELECT report_hours,sum(users_by_time) FROM report_users_by_time where report_date = '#{days}' and gateway_id IN (#{gateway_ids.join(',')}) group by report_hours"
          end
        end
      end
      if sql.present?
        result= ActiveRecord::Base.connection.execute(sql).to_a
        result.each do |res|
          results << [res[0].to_s, res[1]]
        end
      end
      results
    else
      st_date = DateTime.now - (period.to_i).days
      end_date = DateTime.now.strftime("%Y-%m-%d")
      start_date = st_date.strftime("%Y-%m-%d")

      #  SELECT FROM LAST 2 TABLES
      #  FOR CURRENT TABLE
      if DateTime.now.strftime("%m") >= "01" && DateTime.now.strftime("%m") < "07"
        end_table_name = "report_#{DateTime.now.strftime('%Y')}_1"
      else
        end_table_name = "report_#{DateTime.now.strftime('%Y')}_2"
      end
      if gateway_id.present?
        end_sql = " SELECT report_date,users_by_time FROM #{end_table_name} WHERE report_date >= '#{start_date}'
            AND  report_date <= '#{end_date}' AND gateway_id = #{gateway_id}"
        end_sql_result =  ActiveRecord::Base.connection.execute(end_sql).to_a

      else
        if current_user.is_marketer?
          end_sql = " SELECT report_date,users_by_time FROM #{end_table_name} WHERE report_date >= '#{start_date}'
            AND  report_date <= '#{end_date}' AND gateway_id IS NULL"
          end_sql_result =  ActiveRecord::Base.connection.execute(end_sql).to_a
        else
          gateway_ids = current_user.stations.map(&:id)
          if gateway_ids.present?
            end_sql = " SELECT report_date,sum(users_by_time) FROM #{end_table_name} WHERE report_date >= '#{start_date}'
            AND  report_date <= '#{end_date}' AND gateway_id IS NOT NULL AND gateway_id IN (#{gateway_ids.join(',')}) group by report_date"
            end_sql_result =  ActiveRecord::Base.connection.execute(end_sql).to_a
          end
        end
      end


      #  FOR LAST USED TABLE
      if st_date.strftime("%m") >= "01" && st_date.strftime("%m") < "07"
        start_table_name = "report_#{st_date.strftime('%Y')}_1"
      else
        start_table_name = "report_#{st_date.strftime('%Y')}_2"
      end
      if gateway_id.present?
        start_sql = " SELECT report_date,users_by_time FROM #{start_table_name} WHERE report_date >= '#{start_date}'
            AND  report_date <= '#{end_date}' AND gateway_id = '#{gateway_id}' "
        start_sql_result =  ActiveRecord::Base.connection.execute(start_sql).to_a
      else
        if current_user.is_marketer?
          start_sql = " SELECT report_date,users_by_time FROM #{start_table_name} WHERE report_date >= '#{start_date}'
            AND  report_date <= '#{end_date}' AND gateway_id IS NULL"
          start_sql_result =  ActiveRecord::Base.connection.execute(start_sql).to_a
        else
          gateway_ids = current_user.stations.map(&:id)
          if gateway_ids.present?
            start_sql = " SELECT report_date,sum(users_by_time) FROM #{start_table_name} WHERE report_date >= '#{start_date}'
            AND  report_date <= '#{end_date}' AND gateway_id IS NOT NULL AND gateway_id IN (#{gateway_ids.join(',')})  group by report_date"
            start_sql_result =  ActiveRecord::Base.connection.execute(start_sql).to_a
          end
        end
      end

      if end_sql_result.present? && start_sql_result.present?
        format_array =  (end_sql_result + start_sql_result).uniq.sort {|val1,val2| val1[0] <=> val2[0] }
        format_array.each do |array|
          results << [array[0].strftime('%a %e'), array[1]]
        end
      end
      results
    end
  end
  def get_total_minutes(user, number,gateway_id,content_id)

    end_date = DateTime.now
    result = []
    if gateway_id.present? && content_id.blank?
      sql = "SELECT report_date,sum(total_minutes) from report_summary_listen WHERE report_date >= '#{number.days.ago.to_date.strftime("%Y-%m-%d")}'
             AND report_date <= '#{end_date.strftime("%Y-%m-%d")}' AND gateway_id = '#{gateway_id}' AND content_id IS NULL GROUP BY report_date"
    elsif gateway_id.present? && content_id.present?
      sql = "SELECT report_date,sum(total_minutes) from report_summary_listen WHERE report_date >= '#{number.days.ago.to_date.strftime("%Y-%m-%d")}'
             AND report_date <= '#{end_date.strftime("%Y-%m-%d")}' AND content_id = '#{content_id}' AND gateway_id = '#{gateway_id}' GROUP BY report_date"
    elsif gateway_id.blank? && content_id.present?
      sql = "SELECT report_date,sum(total_minutes) from report_summary_listen WHERE report_date >= '#{number.days.ago.to_date.strftime("%Y-%m-%d")}'
             AND report_date <= '#{end_date.strftime("%Y-%m-%d")}' AND content_id = '#{content_id}' AND gateway_id IS NULL GROUP BY report_date"
    else
      if user.is_marketer?
        sql = "SELECT report_date,total_minutes from report_summary_listen WHERE report_date >= '#{number.days.ago.to_date.strftime("%Y-%m-%d")}'
               AND report_date <= '#{end_date.strftime("%Y-%m-%d")}' AND gateway_id IS NULL AND content_id IS NULL GROUP BY report_date"
      else
        gateway_ids = current_user.stations.map(&:id)
        if gateway_ids.present?
          sql = "SELECT report_date,sum(total_minutes) as total_minutes from report_summary_listen WHERE report_date >= '#{number.days.ago.to_date.strftime("%Y-%m-%d")}'
               AND report_date <= '#{end_date.strftime("%Y-%m-%d")}' AND content_id IS NULL AND gateway_id  IN (#{gateway_ids.join(',')}) GROUP BY report_date"
        end
      end
    end
    if sql.present?
      sql_result =  ActiveRecord::Base.connection.execute(sql).to_a
      result =[]
      sql_result.each do |res|
        result << [res[0].strftime("%a %e"),res[1]]
      end
    end
    result
  end

  def get_hourly_minutes
    graph = HourlyMinutesGraph.new(current_user)
    render :json => graph.results
  end

  def get_daily_minutes
    graph = DailyMinutesGraph.new(current_user)
    render :json => graph.results
  end

  def get_weekly_minutes
    graph = WeeklyMinutesGraph.new(current_user)
    render :json => graph.results
  end
end