class ApplicationController < ActionController::Base
  include PublicActivity::StoreController
  skip_after_filter :intercom_rails_auto_include
  protect_from_forgery
  layout :layout_by_resource
  before_filter :set_first_station
  before_filter :set_last_seen_at
  before_filter :get_intercom_notifications

  SEVEN_DAYS = 7
  TWENTY_FOUR_HOURS = 1
  SEVEN_DAYS_BY_HOURS = 8
  THIRTY_DAYS = 30
  SLIDER_SIZE = 6
  SLIDER_PAGE_SIZE = 16
  SLIDER_FIRST_PAGE_SIZE = 16

  def after_sign_in_path_for(user)
    if user.valid_password?(user.default_password)
      reset_password_users_path
    else
      root_url
    end
  end

  def thirdparty?
    current_user.is_thirdparty?
  end
  helper_method :thirdparty?

  def broadcaster?
    current_user.is_broadcaster?
  end
  helper_method :broadcaster?

  def marketer?
    current_user.is_marketer?
  end
  helper_method :marketer?

  def rca?
    current_user.is_rca?
  end
  helper_method :rca?

  
  def layout_by_resource
    if devise_controller? || %w{reset_password submit_reset_password}.include?(params[:action])
      "login"
    elsif params[:controller] == "pending_users" && %w{new create save}.include?(params[:action])
      "framed"
    else
      "application"
    end
  end

  def get_stations
    if current_user
      if !params[:slider_search_enabled] || params[:slider_search_enabled] == "false"
        if current_user.is_marketer?
          @stations = current_user.stations.top_stations(current_user, {day: 1, limit: SLIDER_SIZE}) if current_user
        else
          @stations = current_user.stations
        end
        @station_id ||= @stations.try(:first).try(:id)
        if @station_id
          @station = DataGateway.find @station_id
        end
      else
        @slider_country_id = params[:country_id]
        @slider_rca_id = params[:rca_id]
        @slider_query = params[:query]
        @stations = current_user.stations.filter(@slider_query, @slider_country_id.to_i, @slider_rca_id.to_i, current_user)
      end
      @selected_station_id = params[:station_id]
    end
  end

  def slider_content
    params[:page] ||= 1
    params[:search] ||= ''
    params[:country_id] ||= ''
    params[:rca_id] ||= ''
    @count, @stations = current_user.stations.filter(params[:search], params[:country_id].to_i, params[:rca_id].to_i, current_user, params[:page].to_i)
    @controller_name = params[:controller_name]
    @rca_ids = []
    if current_user.is_rca?
      @rca_ids = current_user.data_group_rcas.collect(&:id) if current_user.data_group_rcas.present?
    end
    render partial: "shared/slider_search"
    # render json: @count
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end

  def convert_seconds_to_minutes(seconds)
    return (seconds.to_f / 1.minutes).round(2)
  end
  
  def user_title
    if current_user
      "#{current_user.title} (#{current_user.email})"
    end
  end

  def get_intercom_notifications
  end

  protected

  def set_first_station
    if current_user
      get_first_station
      if @_stations.present?
        @stations = [@_stations.first]
      else
        @stations = DataGateway.new
      end
    end
  end
  
  def get_first_station
    if current_user
      country_id = params[:country_id]
      if current_user.is_marketer?
        rca_id = params[:rca_id]
      else 
        rca_id = ''
      end
      query = params[:query]
      @_stations = current_user.stations
      if query.present? || country_id.present? || rca_id.present?
        @_stations = @_stations.filter(query, country_id.to_i, rca_id.to_i, current_user, 1)
      end
      if @_stations.present?
        @first_station = @_stations.first
      else
        @first_station = DataGateway.new
      end
    end
  end

  def set_last_seen_at
    if current_user && session[:session_activity_id]
      session_activity_id = session[:session_activity_id]
      public_activity = PublicActivity::Activity.find(session_activity_id) rescue nil
      if public_activity.present?
        time_period = Time.now - public_activity.created_at
        public_activity.parameters = { :time_period => time_period, :time => Time.now }
        public_activity.save
      end
    end
  end 

  def restrict_admin_only
    unless marketer?
      flash[:error] = 'Unauthorized access.'
      redirect_to root_path
    end
  end

  def restrict_to_admin_rca_only
    if broadcaster?
      flash[:error] = 'Unauthorized access.'
      redirect_to root_path
    end
  end

  # new reports methods

  def report_data
    station_ids = params[:station_id].present? ? @all_stations.find(params[:station_id]).id : @all_stations.collect(&:id).join(',')
    did_id = params[:did].present? ? " and c.id = '#{params[:did]}' " : ' '
    sql = "
      select
        report.report_date,
        sum(sum_new_users_b) sum_new_users,
        sum(sum_active_users_b) sum_active_users,
        sum(sum_sessions_b) sum_sessions,
        sum(sum_total_minutes_a) sum_total_minutes
      from
        ("
    unless params[:did].present?
      sql += "
            select
                    a.report_date,
                    0 sum_new_users_b,
                    0 sum_active_users_b,
                    0 sum_sessions_b,
                    sum(a.total_minutes) sum_total_minutes_a
            from report_total_minutes_by_hour_actual a
            where a.report_date >= '#{@dt.at_beginning_of_month}'
                    and a.report_date <= '#{@dt.at_end_of_month}'
                    and a.gateway_id in (#{(station_ids)})
            group by a.report_date
            union "
    end
    sql += "
          select
                  b.report_date,
                  sum(b.new_users) sum_new_users_b,
                  sum(b.active_users) sum_active_users_b,
                  sum(b.sessions) sum_sessions_b,
                  #{(params[:did].present? ? 'sum(b.total_minutes)' : '0')} sum_total_minutes_a
          from report_by_did_2015_2 b
            inner join data_entryway c on b.entryway_id = c.id
          where b.report_date >= '#{@dt.at_beginning_of_month}'
                  and b.report_date <= '#{@dt.at_end_of_month}'
                  and c.gateway_id in (#{(station_ids)}) #{did_id}
          group by b.report_date
        ) report
    group by report.report_date"
    raw = ActiveRecord::Base.connection.execute(sql).to_a
    result = []
    days = (@dt.at_beginning_of_month..@dt.at_end_of_month).to_a
    days.each do |d|
      filtered_data = nil
      raw.each do |data|
        if data[0] == d
          data[0] = [d.strftime('%b'), d.strftime('%d'), d.strftime('%A')]
          filtered_data = data
        end
      end
      filtered_data.present? ? (result << filtered_data ) : result << [[d.strftime('%b'), d.strftime('%d'), d.strftime('%A')], 0, 0, 0, 0, 0]
    end
    result
  end

  def sort_out(result)
    if params[:column].present? and params[:target].present? and params[:order].present?
      result = result.sort_by{|x| x[params[:column].to_i][(params[:target] == 'percent' ? 1 : 0)]}
      result = result.reverse if params[:order] == 'desc'
    end
    result
  end

  def get_top_3_percentage(sql_result)
    sql_result.each do |minutes|
      # last week days
      percentage = ((minutes[2].to_i-minutes[1].to_i).to_f/minutes[1].to_i)*100 rescue 0
      minutes[2] = [minutes[2], percentage.to_s.to_i]
      # last week
      percentage = ((minutes[3].to_i-minutes[2][0].to_i).to_f/minutes[2][0].to_i)*100 rescue 0
      minutes[3] = [minutes[3], percentage.to_s.to_i]
    end
    sql_result
  end

  def get_minutes_percentage(sql_result)
    sql_result.each do |minutes|
      # week_5
      percentage = ((minutes[3].to_i-minutes[2].to_i).to_f/minutes[2].to_i)*100 rescue 0
      minutes[3] = [minutes[3], (percentage.to_i rescue 0)]
      # week_4
      percentage = ((minutes[4].to_i-minutes[3][0].to_i).to_f/minutes[3][0].to_i)*100 rescue 0
      minutes[4] = [minutes[4], (percentage.to_i rescue 0)]
      # week_3
      percentage = ((minutes[5].to_i-minutes[4][0].to_i).to_f/minutes[4][0].to_i)*100 rescue 0
      minutes[5] = [minutes[5], (percentage.to_i rescue 0)]
      # week_2
      percentage = ((minutes[6].to_i-minutes[5][0].to_i).to_f/minutes[5][0].to_i)*100 rescue 0
      minutes[6] = [minutes[6], (percentage.to_i rescue 0)]
      # current
      percentage = ((minutes[8].to_i-minutes[7].to_i).to_f/minutes[7].to_i)*100 rescue 0
      minutes[8] = [minutes[8], (percentage.to_i rescue 0)]
    end
  end

  def rca_top_3(trend, orientation='rca.id', for_rca=false)
    startdate = @cm.at_beginning_of_week(:sunday)
    ranges = {last_last_week_days: [(startdate - 14.days).at_beginning_of_week(:sunday), (startdate - 14.days).at_beginning_of_week(:sunday) + (@cm - startdate.at_beginning_of_week(:sunday)).days],
              last_week_days: [(startdate - 7.days).at_beginning_of_week(:sunday), (startdate - 7.days).at_beginning_of_week(:sunday) + (@cm - startdate.at_beginning_of_week(:sunday)).days - 1.day],
              current_week: [startdate, @cm - 1.day]}
    @top_3_labels = [[ranges[:last_last_week_days][0].strftime('%b %d'), ranges[:last_last_week_days][1].strftime('%b %d')],
                     [ranges[:last_week_days][0].strftime('%b %d'), ranges[:last_week_days][1].strftime('%b %d')],
                     [ranges[:current_week][0].strftime('%b %d'), ranges[:current_week][1].strftime('%b %d')]]
    rca_filter = " and rca.id = #{params[:rca_id]} "
    sql = "select res.*, res.current_week + res.last_week_days total_minutes
            from ( select
                      rca.title rca_title,
                      sum(case when (date(report.report_date) >= '#{ranges[:last_last_week_days][0]}' and date(report.report_date) <= '#{ranges[:last_last_week_days][1]}') then report.total_minutes else 0 end) last_last_week_days,
                      sum(case when (date(report.report_date) >= '#{ranges[:last_week_days][0]}' and date(report.report_date) <= '#{ranges[:last_week_days][1]}') then report.total_minutes else 0 end) last_week_days,
                      sum(case when (date(report.report_date) >= '#{ranges[:current_week][0]}' and date(report.report_date) <= '#{ranges[:current_week][1]}') then report.total_minutes else 0 end) current_week,
                      dg.title dg_title
            from report_total_minutes_by_day report
                inner join data_gateway dg on report.gateway_id = dg.id
                inner join data_group_rca rca on dg.rca_id = rca.id
            where dg.title is not null
                and dg.is_deleted = 0
                and rca.is_deleted = 0
                and rca.title is not null
                #{rca_filter if for_rca}
                and (date(report.report_date) >= '#{ranges[:last_last_week_days][0]}' and date(report.report_date) <= '#{@cm}')
            group by #{orientation}
            ) res
            where res.current_week > 1000 and res.last_week_days > 1000
            order by current_week desc, rca_title asc"
    raw_result = get_top_3_percentage(ActiveRecord::Base.connection.execute(sql).to_a)
    result = raw_result.sort_by{|x| x[3][1]}
    result = result.reverse if trend == 'desc'
    return result.take(3)
  end

  def get_weekly_rca_minutes(orientation = 'rca.id')
    startdate = @cm.at_beginning_of_week(:sunday)
    enddate = startdate - 35.days
    ranges = {current_week: [startdate, @cm - 1.day],
              last_week_days: [(startdate - 7.days).at_beginning_of_week(:sunday), (startdate - 7.days).at_beginning_of_week(:sunday) + (@cm - startdate.at_beginning_of_week(:sunday)).days - 1.day],
              week_2: [(startdate - 7.days).at_beginning_of_week(:sunday), (startdate - 7.days).at_end_of_week(:sunday)],
              week_3: [(startdate - 14.days).at_beginning_of_week(:sunday), (startdate - 14.days).at_end_of_week(:sunday)],
              week_4: [(startdate - 21.days).at_beginning_of_week(:sunday), (startdate - 21.days).at_end_of_week(:sunday)],
              week_5: [(startdate - 28.days).at_beginning_of_week(:sunday), (startdate - 28.days).at_end_of_week(:sunday)],
              week_6: [(startdate - 35.days).at_beginning_of_week(:sunday), (startdate - 35.days).at_end_of_week(:sunday)]}
    @week_labels = [[ranges[:last_week_days][0].strftime('%b %d'), ranges[:last_week_days][1].strftime('%b %d'), (ranges[:last_week_days][1] - ranges[:last_week_days][0]).to_i],
                    [ranges[:week_2][0].strftime('%b %d'), ranges[:week_2][1].strftime('%b %d'), (ranges[:week_2][1] - ranges[:week_2][0]).to_i],
                    [ranges[:week_3][0].strftime('%b %d'), ranges[:week_3][1].strftime('%b %d'), (ranges[:week_3][1] - ranges[:week_3][0]).to_i],
                    [ranges[:week_4][0].strftime('%b %d'), ranges[:week_4][1].strftime('%b %d'), (ranges[:week_4][1] - ranges[:week_4][0]).to_i],
                    [ranges[:week_5][0].strftime('%b %d'), ranges[:week_5][1].strftime('%b %d'), (ranges[:week_5][1] - ranges[:week_5][0]).to_i],
                    [ranges[:current_week][0].strftime('%b %d'), ranges[:current_week][1].strftime('%b %d'), (ranges[:current_week][1] - ranges[:current_week][0]).to_i]]
    filtered_rca = " and rca_id = '#{params[:rca_id]}' " if params[:rca_id].present?
    sql = "
    select res.*, res.current_week + res.week_2 + res.week_3 + res.week_4 + res.week_5 total_minutes
      from (select
                dg.title dg_title,
                rca.title rca_title,
                sum(case when (date(report.report_date) >= '#{ranges[:week_6][0]}' and date(report.report_date) <= '#{ranges[:week_6][1]}') then report.total_minutes else 0 end) week_6,
                sum(case when (date(report.report_date) >= '#{ranges[:week_5][0]}' and date(report.report_date) <= '#{ranges[:week_5][1]}') then report.total_minutes else 0 end) week_5,
                sum(case when (date(report.report_date) >= '#{ranges[:week_4][0]}' and date(report.report_date) <= '#{ranges[:week_4][1]}') then report.total_minutes else 0 end) week_4,
                sum(case when (date(report.report_date) >= '#{ranges[:week_3][0]}' and date(report.report_date) <= '#{ranges[:week_3][1]}') then report.total_minutes else 0 end) week_3,
                sum(case when (date(report.report_date) >= '#{ranges[:week_2][0]}' and date(report.report_date) <= '#{ranges[:week_2][1]}') then report.total_minutes else 0 end) week_2,
                sum(case when (date(report.report_date) >= '#{ranges[:last_week_days][0]}' and date(report.report_date) <= '#{ranges[:last_week_days][1]}') then report.total_minutes else 0 end) last_week_days,
                sum(case when (date(report.report_date) >= '#{ranges[:current_week][0]}' and date(report.report_date) <= '#{ranges[:current_week][1]}') then report.total_minutes else 0 end) current_week
        from report_total_minutes_by_day report
                inner join data_gateway dg on report.gateway_id = dg.id
                inner join data_group_rca rca on dg.rca_id = rca.id
        where dg.title is not null #{filtered_rca}
                and dg.is_deleted = 0
                and rca.is_deleted = 0
                and rca.title is not null
                and date(report.report_date) >= '#{enddate}' and date(report.report_date) <= '#{@cm}'
        group by #{orientation}
        ) res
        where res.current_week > 1000 and res.week_2 > 1000 and res.week_3 > 1000 and res.week_4 > 1000 and res.week_5 > 1000
        order by total_minutes desc, rca_title asc"
    ActiveRecord::Base.connection.execute(sql).to_a
    # sql
  end

  def country_top_3(trend)
    startdate = @cm.at_beginning_of_week(:sunday)
    ranges = {last_last_week_days: [(startdate - 14.days).at_beginning_of_week(:sunday), (startdate - 14.days).at_beginning_of_week(:sunday) + (@cm - startdate.at_beginning_of_week(:sunday)).days],
              last_week_days: [(startdate - 7.days).at_beginning_of_week(:sunday), (startdate - 7.days).at_beginning_of_week(:sunday) + (@cm - startdate.at_beginning_of_week(:sunday)).days - 1.day],
              current_week: [startdate, @cm - 1.day]}
    @top_3_labels = [[ranges[:last_last_week_days][0].strftime('%b %d'), ranges[:last_last_week_days][1].strftime('%b %d')],
                     [ranges[:last_week_days][0].strftime('%b %d'), ranges[:last_week_days][1].strftime('%b %d')],
                     [ranges[:current_week][0].strftime('%b %d'), ranges[:current_week][1].strftime('%b %d')]]
    sql = "select res.*, res.current_week + res.last_week_days total_minutes
            from ( select
                      country.title country_title,
                      sum(case when (date(report.report_date) >= '#{ranges[:last_last_week_days][0]}' and date(report.report_date) <= '#{ranges[:last_last_week_days][1]}') then report.total_minutes else 0 end) last_last_week_days,
                      sum(case when (date(report.report_date) >= '#{ranges[:last_week_days][0]}' and date(report.report_date) <= '#{ranges[:last_week_days][1]}') then report.total_minutes else 0 end) last_week_days,
                      sum(case when (date(report.report_date) >= '#{ranges[:current_week][0]}' and date(report.report_date) <= '#{ranges[:current_week][1]}') then report.total_minutes else 0 end) current_week
            from report_total_minutes_by_day report
                inner join data_gateway dg on report.gateway_id = dg.id
                inner join data_group_country country on dg.country_id = country.id
            where dg.title is not null
                and dg.is_deleted = 0
                and country.is_deleted = 0
                and country.title is not null
                and (date(report.report_date) >= '#{ranges[:last_last_week_days][0]}' and date(report.report_date) <= '#{@cm}')
            group by country.id
            ) res
            where res.current_week > 1000 and res.last_week_days > 1000
            order by current_week desc, country_title asc"
    raw_result = get_top_3_percentage(ActiveRecord::Base.connection.execute(sql).to_a)
    result = raw_result.sort_by{|x| x[3][1]}
    result = result.reverse if trend == 'desc'
    return result.take(3)
  end

  def get_weekly_country_minutes
    startdate = @cm.at_beginning_of_week(:sunday)
    enddate = startdate - 35.days
    ranges = {current_week: [startdate, @cm - 1.day],
              last_week_days: [(startdate - 7.days).at_beginning_of_week(:sunday), (startdate - 7.days).at_beginning_of_week(:sunday) + (@cm - startdate.at_beginning_of_week(:sunday)).days - 1.day],
              week_2: [(startdate - 7.days).at_beginning_of_week(:sunday), (startdate - 7.days).at_end_of_week(:sunday)],
              week_3: [(startdate - 14.days).at_beginning_of_week(:sunday), (startdate - 14.days).at_end_of_week(:sunday)],
              week_4: [(startdate - 21.days).at_beginning_of_week(:sunday), (startdate - 21.days).at_end_of_week(:sunday)],
              week_5: [(startdate - 28.days).at_beginning_of_week(:sunday), (startdate - 28.days).at_end_of_week(:sunday)],
              week_6: [(startdate - 35.days).at_beginning_of_week(:sunday), (startdate - 35.days).at_end_of_week(:sunday)]}
    @week_labels = [[ranges[:last_week_days][0].strftime('%b %d'), ranges[:last_week_days][1].strftime('%b %d'), (ranges[:last_week_days][1] - ranges[:last_week_days][0]).to_i],
                    [ranges[:week_2][0].strftime('%b %d'), ranges[:week_2][1].strftime('%b %d'), (ranges[:week_2][1] - ranges[:week_2][0]).to_i],
                    [ranges[:week_3][0].strftime('%b %d'), ranges[:week_3][1].strftime('%b %d'), (ranges[:week_3][1] - ranges[:week_3][0]).to_i],
                    [ranges[:week_4][0].strftime('%b %d'), ranges[:week_4][1].strftime('%b %d'), (ranges[:week_4][1] - ranges[:week_4][0]).to_i],
                    [ranges[:week_5][0].strftime('%b %d'), ranges[:week_5][1].strftime('%b %d'), (ranges[:week_5][1] - ranges[:week_5][0]).to_i],
                    [ranges[:current_week][0].strftime('%b %d'), ranges[:current_week][1].strftime('%b %d'), (ranges[:current_week][1] - ranges[:current_week][0]).to_i]]
    filtered_rca = " and country_id = '#{params[:country_id]}' " if params[:country_id].present?
    sql = "
    select res.*, res.current_week + res.week_2 + res.week_3 + res.week_4 + res.week_5 total_minutes
      from (select
                country.id country_id,
                country.title country_title,
                sum(case when (date(report.report_date) >= '#{ranges[:week_6][0]}' and date(report.report_date) <= '#{ranges[:week_6][1]}') then report.total_minutes else 0 end) week_6,
                sum(case when (date(report.report_date) >= '#{ranges[:week_5][0]}' and date(report.report_date) <= '#{ranges[:week_5][1]}') then report.total_minutes else 0 end) week_5,
                sum(case when (date(report.report_date) >= '#{ranges[:week_4][0]}' and date(report.report_date) <= '#{ranges[:week_4][1]}') then report.total_minutes else 0 end) week_4,
                sum(case when (date(report.report_date) >= '#{ranges[:week_3][0]}' and date(report.report_date) <= '#{ranges[:week_3][1]}') then report.total_minutes else 0 end) week_3,
                sum(case when (date(report.report_date) >= '#{ranges[:week_2][0]}' and date(report.report_date) <= '#{ranges[:week_2][1]}') then report.total_minutes else 0 end) week_2,
                sum(case when (date(report.report_date) >= '#{ranges[:last_week_days][0]}' and date(report.report_date) <= '#{ranges[:last_week_days][1]}') then report.total_minutes else 0 end) last_week_days,
                sum(case when (date(report.report_date) >= '#{ranges[:current_week][0]}' and date(report.report_date) <= '#{ranges[:current_week][1]}') then report.total_minutes else 0 end) current_week
        from report_total_minutes_by_day report
                inner join data_gateway dg on report.gateway_id = dg.id
                inner join data_group_country country on dg.country_id = country.id
        where dg.title is not null #{filtered_rca}
                and dg.is_deleted = 0
                and country.is_deleted = 0
                and country.title is not null
                and date(report.report_date) >= '#{enddate}' and date(report.report_date) <= '#{@cm}'
        group by country.id
        ) res
        where res.current_week > 1000 and res.week_2 > 1000 and res.week_3 > 1000 and res.week_4 > 1000 and res.week_5 > 1000
        order by total_minutes desc, country_title asc"
    ActiveRecord::Base.connection.execute(sql).to_a
    # sql
  end

  def get_weekly_country_users
    startdate = @cm.at_beginning_of_week(:sunday)
    enddate = startdate - 35.days
    ranges = {current_week: [startdate, @cm - 1.day],
              last_week_days: [(startdate - 7.days).at_beginning_of_week(:sunday), (startdate - 7.days).at_beginning_of_week(:sunday) + (@cm - startdate.at_beginning_of_week(:sunday)).days - 1.day],
              week_2: [(startdate - 7.days).at_beginning_of_week(:sunday), (startdate - 7.days).at_end_of_week(:sunday)],
              week_3: [(startdate - 14.days).at_beginning_of_week(:sunday), (startdate - 14.days).at_end_of_week(:sunday)],
              week_4: [(startdate - 21.days).at_beginning_of_week(:sunday), (startdate - 21.days).at_end_of_week(:sunday)],
              week_5: [(startdate - 28.days).at_beginning_of_week(:sunday), (startdate - 28.days).at_end_of_week(:sunday)],
              week_6: [(startdate - 35.days).at_beginning_of_week(:sunday), (startdate - 35.days).at_end_of_week(:sunday)]}
    @week_labels = [[ranges[:last_week_days][0].strftime('%b %d'), ranges[:last_week_days][1].strftime('%b %d'), (ranges[:last_week_days][1] - ranges[:last_week_days][0]).to_i],
                    [ranges[:week_2][0].strftime('%b %d'), ranges[:week_2][1].strftime('%b %d'), (ranges[:week_2][1] - ranges[:week_2][0]).to_i],
                    [ranges[:week_3][0].strftime('%b %d'), ranges[:week_3][1].strftime('%b %d'), (ranges[:week_3][1] - ranges[:week_3][0]).to_i],
                    [ranges[:week_4][0].strftime('%b %d'), ranges[:week_4][1].strftime('%b %d'), (ranges[:week_4][1] - ranges[:week_4][0]).to_i],
                    [ranges[:week_5][0].strftime('%b %d'), ranges[:week_5][1].strftime('%b %d'), (ranges[:week_5][1] - ranges[:week_5][0]).to_i],
                    [ranges[:current_week][0].strftime('%b %d'), ranges[:current_week][1].strftime('%b %d'), (ranges[:current_week][1] - ranges[:current_week][0]).to_i]]
    filtered_rca = " and country_id = '#{params[:country_id]}' " if params[:country_id].present?
    sql = "
    select res.*, res.current_week + res.week_2 + res.week_3 + res.week_4 + res.week_5 total_users
      from (select
                country.id country_id,
                country.title country_title,
                sum(case when (date(report.report_date) >= '#{ranges[:week_6][0]}' and date(report.report_date) <= '#{ranges[:week_6][1]}') then report.users_by_time else 0 end) week_6,
                sum(case when (date(report.report_date) >= '#{ranges[:week_5][0]}' and date(report.report_date) <= '#{ranges[:week_5][1]}') then report.users_by_time else 0 end) week_5,
                sum(case when (date(report.report_date) >= '#{ranges[:week_4][0]}' and date(report.report_date) <= '#{ranges[:week_4][1]}') then report.users_by_time else 0 end) week_4,
                sum(case when (date(report.report_date) >= '#{ranges[:week_3][0]}' and date(report.report_date) <= '#{ranges[:week_3][1]}') then report.users_by_time else 0 end) week_3,
                sum(case when (date(report.report_date) >= '#{ranges[:week_2][0]}' and date(report.report_date) <= '#{ranges[:week_2][1]}') then report.users_by_time else 0 end) week_2,
                sum(case when (date(report.report_date) >= '#{ranges[:last_week_days][0]}' and date(report.report_date) <= '#{ranges[:last_week_days][1]}') then report.users_by_time else 0 end) last_week_days,
                sum(case when (date(report.report_date) >= '#{ranges[:current_week][0]}' and date(report.report_date) <= '#{ranges[:current_week][1]}') then report.users_by_time else 0 end) current_week
        from report_2015_1 report
                inner join data_gateway dg on report.gateway_id = dg.id
                inner join data_group_country country on dg.country_id = country.id
        where dg.title is not null #{filtered_rca}
                and dg.is_deleted = 0
                and country.is_deleted = 0
                and country.title is not null
                and date(report.report_date) >= '#{enddate}' and date(report.report_date) <= '#{@cm}'
        group by country.id
        ) res where res.current_week > 1000 and res.week_2 > 1000 and res.week_3 > 1000 and res.week_4 > 1000 and res.week_5 > 1000
        order by total_users desc, country_title asc"
    ActiveRecord::Base.connection.execute(sql).to_a
    # sql
  end

  def country_users_top_3(trend)
    startdate = @cm.at_beginning_of_week(:sunday)
    ranges = {last_last_week_days: [(startdate - 14.days).at_beginning_of_week(:sunday), (startdate - 14.days).at_beginning_of_week(:sunday) + (@cm - startdate.at_beginning_of_week(:sunday)).days],
              last_week_days: [(startdate - 7.days).at_beginning_of_week(:sunday), (startdate - 7.days).at_beginning_of_week(:sunday) + (@cm - startdate.at_beginning_of_week(:sunday)).days - 1.day],
              current_week: [startdate, @cm - 1.day]}
    @top_3_labels = [[ranges[:last_last_week_days][0].strftime('%b %d'), ranges[:last_last_week_days][1].strftime('%b %d')],
                     [ranges[:last_week_days][0].strftime('%b %d'), ranges[:last_week_days][1].strftime('%b %d')],
                     [ranges[:current_week][0].strftime('%b %d'), ranges[:current_week][1].strftime('%b %d')]]
    sql = "select res.*, res.current_week + res.last_week_days total_users
            from ( select
                      country.title country_title,
                      sum(case when (date(report.report_date) >= '#{ranges[:last_last_week_days][0]}' and date(report.report_date) <= '#{ranges[:last_last_week_days][1]}') then report.users_by_time else 0 end) last_last_week_days,
                      sum(case when (date(report.report_date) >= '#{ranges[:last_week_days][0]}' and date(report.report_date) <= '#{ranges[:last_week_days][1]}') then report.users_by_time else 0 end) last_week_days,
                      sum(case when (date(report.report_date) >= '#{ranges[:current_week][0]}' and date(report.report_date) <= '#{ranges[:current_week][1]}') then report.users_by_time else 0 end) current_week
            from report_2015_1 report
                inner join data_gateway dg on report.gateway_id = dg.id
                inner join data_group_country country on dg.country_id = country.id
            where dg.title is not null
                and dg.is_deleted = 0
                and country.is_deleted = 0
                and country.title is not null
                and (date(report.report_date) >= '#{ranges[:last_last_week_days][0]}' and date(report.report_date) <= '#{@cm}')
            group by country.id
            ) res
            where res.current_week > 1000 and res.last_week_days > 1000
            order by current_week desc, country_title asc"
    raw_result = get_top_3_percentage(ActiveRecord::Base.connection.execute(sql).to_a)
    result = raw_result.sort_by{|x| x[3][1]}
    result = result.reverse if trend == 'desc'
    return result.take(3)
  end

  def validate_email(email)
    regx = /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/
    (email =~ regx)
  end

  def hostname
    request.protocol + request.host_with_port
  end
  helper_method :hostname

rescue_from ActionController::RoutingError, :with => :render_404

 private
  def render_404(exception = nil)
    if exception
        logger.info "Rendering 404: #{exception.message}"
    end
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

end
