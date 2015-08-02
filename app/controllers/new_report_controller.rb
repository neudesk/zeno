class NewReportController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_user, only: [:rca_minutes_minutes, :country_minutes_minutes]
  before_filter :slider_params, only: [:index, :graph, :get_users_by_time, :get_minutes_report]

  def index
    @now = Date.today
    params[:date] ||= {month: @now.month, year: @now.year}
    @dt = Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1)
    @result = report_data
  end

  def graph
  end

  def get_minutes_report
    station_ids = @all_stations.collect(&:id).join(',')
    now = Time.now.in_time_zone('Eastern Time (US & Canada)')
    params[:minutes_report] ||= "7days"
    station_ids = params[:station_id] if params[:station_id].present?
    where = " report.gateway_id in (#{station_ids}) AND "
    array_skip = 1
    case params[:minutes_report]
      when "7days"
        where += " (report.report_date >= '#{(now - 8.days).strftime('%Y-%m-%d')}' AND report.report_date <= '#{now.strftime('%Y-%m-%d')}') "
      when "30days"
        where += " (report.report_date >= '#{(now - 31.days).strftime('%Y-%m-%d')}' AND report.report_date <= '#{now.strftime('%Y-%m-%d')}') "
        array_skip = 3
      when "90days"
        where += " (report.report_date >= '#{(now - 91.days).strftime('%Y-%m-%d')}' AND report.report_date <= '#{now.strftime('%Y-%m-%d')}') "
        array_skip = 8
    end
    sql = "	select
              report.report_date,
              sum(report.total_minutes) sum_total_minutes
            from report_total_minutes_by_hour_actual report
            where #{where}
            group by report.report_date"
    raw = ActiveRecord::Base.connection.execute(sql).to_a
    raw = raw.each_slice(array_skip).map(&:last)
    result = raw.map {|x| [x[0].strftime('%b %d'), x[1]]}
    render json: result
  end

  def get_users_by_time
    params[:users_by_time] ||= "today"
    station_ids = @all_stations.collect(&:id).join(',')
    now = Time.now.in_time_zone('Eastern Time (US & Canada)')
    case params[:users_by_time]
      when "today"
        where = " report.report_date = '#{now.strftime('%Y-%m-%d')}' "
        group_by = 'report_hours'
        table = 'report_users_by_time'
        report_time_column = " report_hours, "
      when "yesterday"
        where = " report.report_date = '#{(now - 1.day).strftime('%Y-%m-%d')}' "
        group_by = 'report_hours'
        table = 'report_users_by_time'
        report_time_column = " report_hours, "
      when "7days"
        where = " (report.report_date >= '#{(now - 8.days).strftime('%Y-%m-%d')}' AND report.report_date <= '#{now.strftime('%Y-%m-%d')}') "
        array_skip = 1
        group_by = 'report_date'
        table = 'report_2015_1'
        report_time_column = " report_date, "
      when "30days"
        where = " (report.report_date >= '#{(now - 31.days).strftime('%Y-%m-%d')}' AND report.report_date <= '#{now.strftime('%Y-%m-%d')}') "
        array_skip = 3
        group_by = 'report_date'
        table = 'report_2015_1'
        report_time_column = " report_date, "
      when "90days"
        array_skip = 8
        where = " (report.report_date >= '#{(now - 91.days).strftime('%Y-%m-%d')}' AND report.report_date <= '#{now.strftime('%Y-%m-%d')}') "
        group_by = 'report_date'
        table = 'report_2015_1'
        report_time_column = " report_date, "
    end
    station_ids = params[:station_id] if params[:station_id].present?
    where += " and report.gateway_id in (#{station_ids}) "
    sql = "select
            #{report_time_column}
            sum(users_by_time) sum_users_by_time
          from #{table} report
          where #{where}
          group by #{group_by}"
    raw = ActiveRecord::Base.connection.execute(sql).to_a
    result = []
    if params[:users_by_time] == "today" or params[:users_by_time] == "yesterday"
      (0..23).each do |h|
        local_data = nil
        raw.each do |data|
          if data[0] == h
            htime = (h > 11 ? "#{(h > 12 ? h - 12 : h)} pm" : "#{h} am")
            data[0] = htime
            local_data = data
          end
        end
        htime = (h > 11 ? "#{(h > 12 ? h - 12 : h)} pm" : "#{h} am")
        local_data.present? ? (result << local_data) : (result << [htime, 0])
      end
    else
      raw = raw.each_slice(array_skip).map(&:last)
      result = raw.map{|x| [x[0].strftime('%b %d'), x[1]]}
    end
    render json: result
  end

  def rca_minutes_minutes
    @cm = Date.today
    @rcas = DataGroupRca.select([:id, :title]).order('title')
    params[:column] ||= 8
    params[:target] ||= 'minutes'
    params[:order] ||= 'desc'

    # weekly minutes and percentage
    sql_result = get_weekly_rca_minutes
    result = get_minutes_percentage(sql_result)
    @minutes = sort_out(result)
    # @minutes = Kaminari.paginate_array(result).page(params[:page]).per(10)

    # top 3 minutes and percentage
    @top_3 = rca_top_3('desc')

    # bottom 3 minutes and percentage
    @bottom_3 = rca_top_3('asc')
    # render json: params
  end

  def country_minutes_minutes
    @cm = Date.today
    params[:column] ||= 8
    params[:target] ||= 'minutes'
    params[:order] ||= 'desc'
    @countries = DataGroupCountry.select([:id, :title]).order('title')

    # weekly minutes and percentage
    sql_result = get_weekly_country_minutes
    result = get_minutes_percentage(sql_result)
    @minutes = sort_out(result)
    # @minutes = Kaminari.paginate_array(result).page(params[:page]).per(10)

    # top 3 minutes and percentage
    @top_3 = country_top_3('desc')

    # bottom 3 minutes and percentage
    @bottom_3 = country_top_3('asc')
  end

  def country_users
    @cm = Date.today
    params[:column] ||= 8
    params[:target] ||= 'minutes'
    params[:order] ||= 'desc'
    @countries = DataGroupCountry.select([:id, :title]).order('title')

    # weekly minutes and percentage
    sql_result = get_weekly_country_users
    result = get_minutes_percentage(sql_result)
    @users = sort_out(result)

    # top 3 users and percentage
    @top_3 = country_users_top_3('desc')

    # bottom 3 users and percentage
    @bottom_3 = country_users_top_3('asc')
    # render json: @users
  end

  def slider_params
    @current_station = DataGateway.find_by_id(params[:station_id]) rescue nil
    @entryways = DataEntryway.where(gateway_id: @current_station.id) if @current_station.present?
    @all_stations = (current_user.is_marketer? ? current_user.stations.unscoped : current_user.stations)
    @q = @all_stations.search(params[:q])
    @stations = @q.result(distinct: true).page(params[:page]).per(15)
    if @stations.total_pages < params[:page].to_i
      params[:page] = 1
      @stations = @q.result(distinct: true).page(params[:page]).per(15)
    end
    @page = params[:page] || 1
  end

  protected
  def validate_user
    unless current_user.is_marketer?
      redirect_to root_path
    end
  end

end
