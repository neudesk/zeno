class HomeController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :filter_data_to_slides, :only => [:slider_search]
  before_filter :restrict_admin_only, only: [:admin_user_mailer]

  def index
    report_type = params[:type].present? ? params[:type] : "gateway"
    @stations_result = Kaminari.paginate_array(stations(report_type)).page(params[:page]).per(10) if stations(report_type).present?
    @usage_percent = UsageGraph.new(current_user).usage_percent
    @result = get_top_3_stations("rca_id",current_user.id).sort{|a, b| b[3].to_i <=> a[3].to_i} if rca?
    # render json: @result

    if current_user.is_rca?
      @cm = Date.today
      params[:rca_id] ||= current_user.data_group_rcas.first.id
      # weekly minutes and percentage
      sql_result = get_weekly_rca_minutes(orientation='dg.id')
      result = get_minutes_percentage(sql_result)
      @minutes = sort_out(result)
      # top 3 minutes and percentage
      @top_3 = rca_top_3('desc', orientation='dg.id', for_rca=true)
      # bottom 3 minutes and percentage
      @bottom_3 = rca_top_3('asc', orientation='dg.id', for_rca=true)
      # render json: @top_3
    end

  end

  def get_top_3_stations(type,id)
    result = []

    if DateTime.now.strftime("%m") >= "01" && DateTime.now.strftime("%m") < "07"
      table_name = "report_#{DateTime.now.strftime('%Y')}_1"
    else
      table_name = "report_#{DateTime.now.strftime('%Y')}_2"
    end
    where = "AND dg.#{type} = #{id}"

    last_weeks_sql = "SELECT GROUP_CONCAT(res.report_week order by res.report_week ASC),
                      GROUP_CONCAT(total_minutes order by res.report_week ASC),res.title,res.id,count(total_minutes) as total FROM
                      (
                         SELECT WEEK(report.report_date,6) as report_week, sum(total_minutes) as total_minutes,dg.title,dg.id FROM #{table_name} as report
                         INNER JOIN data_gateway as dg on dg.id = report.gateway_id
                         WHERE report_date >= CURDATE() - INTERVAL 5 WEEK and dg.title IS NOT NULL and dg.is_deleted = false
                          #{where}
                         GROUP BY dg.id,report_week
                      ) as res GROUP BY res.id"


    last_weeks_data =ActiveRecord::Base.connection.execute(last_weeks_sql).to_a
    if params["type"] == "minutes"
      last_weeks_data.each do |last|
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

        two_weeks = results.present? && results[3].present? ? results[3] : 0
        one_week = results.present? && results[4].present? ? results[4] : 0

        title = last[2]
        id = last[3]
        result << [title, id, two_weeks.to_i, one_week.to_i]
      end
    else
      last_weeks_data.each do |last|
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

        three_weeks = results.present? && results[2].present? ? results[2] : 0
        two_weeks = results.present? && results[3].present? ? results[3] : 0
        one_week = results.present? && results[4].present? ? results[4] : 0
        second_val,first_val, = 0,0

        if  three_weeks.to_i != 0 && two_weeks.to_i != 0
          second_val = (100-((two_weeks.to_i * 100)/three_weeks.to_i))
        end

        if two_weeks.to_i != 0 && one_week.to_i != 0
          first_val = (100-((one_week.to_i * 100)/two_weeks.to_i))
        end

        title = last[2]
        id = last[3]
        result << [title, id, second_val.to_i, first_val.to_i]
      end
    end
    result
  end

  def user_percent
    result = UsageGraph.new(current_user).usage_percent
    render :json => result
  end

  def track_customize
    broken_down, from_day = get_filter_time(params[:day_id].to_i)
    current_user.track_aggregate_customs(params[:check_list], broken_down, from_day)
    flash[:notice] = "Updated successfully."
    render :nothing => true
  end

  def get_stations
    if params[:type].present?
      @stations_result = Kaminari.paginate_array(stations(params[:type])).page(params[:page]).per(10)
      render :partial => "summary_list_body"
    else
      render :json => {:error => 'required parameters is not present.'}
    end
  end

  def stations(type)
    results = []
    date = (DateTime.now - 15.minutes).strftime("%Y-%m-%d %H:%M:%S")

    where = ""
    where_session = ""
    user_has_stations = true

    if current_user.stations.present?
      where = "and gateway_id in (#{current_user.stations.map(&:id).join(',')})"
      where_session = "and g.id in (#{current_user.stations.map(&:id).join(',')})"
    else
      user_has_stations = false
    end

    if user_has_stations
      case type
      when "gateway"
        sql_now_session = "SELECT  g.id,'', g.title,count(*) FROM now_session as n, data_gateway as g  where n.call_gateway_id=g.id group by g.id "
        sql_log_call ="SELECT
                    gateway_id,count(*),sum(seconds),
                    sum(if( (seconds>=0) and (seconds<60) ,1,0)),
                    sum(if( (seconds>=60) and (seconds<900) ,1,0)) ,
                    sum(if( (seconds>=900) ,1,0))
                  FROM
                    log_call
                  WHERE
                    seconds is not null
                    and date_stop is not null
                    and date_stop> '#{date}'
                   #{where}
                  GROUP by gateway_id "
      when "content"
        sql_now_session = "SELECT conf.id, g.id, CONCAT(if(c.title is null,'-',c.title), ' / ', if(g.title is null,'-',g.title)),count(*)
                    FROM now_session as n, data_content as c, data_gateway as g, data_gateway_conference as conf
                    where n.listen_gateway_conference_id=conf.id and conf.gateway_id=g.id and conf.content_id=c.id #{where_session}
                    group by conf.id "
        sql_log_call = "select
                    gateway_conference_id,count(*),sum(seconds),
                    sum(if( (seconds>=0) and (seconds<60) ,1,0)),
                    sum(if( (seconds>=60) and (seconds<900) ,1,0)) ,
                    sum(if( (seconds>=900) ,1,0))
                  from
                    log_listen
                  where
                    seconds is not null
                    and date_stop is not null
                    and date_stop> '#{date}'
                    group by gateway_conference_id"

      when "entryway"
        sql_now_session = "SELECT e.id, g.id, CONCAT(if(e.title is null,'-',e.title), ' / ', if(g.title is null,'-',g.title)),count(*)
                        FROM now_session as n, data_entryway as e, data_gateway as g
                        where n.call_gateway_id=g.id and n.call_entryway_id=e.id #{where_session}
                        group by e.id "
        sql_log_call = "select
                      entryway_id,count(*),sum(seconds),
                      sum(if( (seconds>=0) and (seconds<60) ,1,0)),
                      sum(if( (seconds>=60) and (seconds<900) ,1,0)) ,
                      sum(if( (seconds>=900) ,1,0))
                    from
                      log_call
                    where
                      seconds is not null
                      and date_stop is not null
                      and date_stop>'#{date}'
                      #{where}
                      group by entryway_id"
      end


      result_now_session = ActiveRecord::Base.connection.execute(sql_now_session).to_a
      result_log_call = ActiveRecord::Base.connection.execute(sql_log_call).to_a

      result_now_session.each do |session|
        item = result_log_call.detect {|r| session[0] == r[0]}
        acd_3_percent,acd_2_percent,acd_3_percent = [0,0,0]
        if item.present?
          if item[1].present? && item[1]> 0 && item[3].present? && item[3]> 0
            acd_1_percent =  100 * (item[3].to_f / item[1].to_f)
          end
          if item[1].present? && item[1]> 0 && item[4].present? && item[4]> 0
            acd_2_percent =  100 * (item[4].to_f / item[1].to_f)
          end
          if item[1].present? && item[1]> 0 && item[5].present? && item[5]> 0
            acd_3_percent =  100 * (item[5].to_f / item[1].to_f)
          end
          results << [item[0], session[2], session[3], item[1], acd_1_percent.to_i, acd_2_percent.to_i, acd_3_percent.to_i]
        end
      end
      results.sort{|a,b| b[2] <=> a[2] }
    end

  end

  def admin_user_mailer
    if request.xhr?
      error = false
      if params[:recipient].empty? or params[:subject].empty? or validate_email(params[:recipient]).nil?
        error = true
      end
      params[:bcc].split(',').each do |cc|
        error = true if validate_email(cc).nil?
      end
      if error
        render json: {error: 1, message: 'Failed to send, Please check fields.'}
      else
        if UserMailer.mail_new_user(params[:template], params[:recipient], params[:subject], params[:attachments], params[:bcc].split(',')).deliver
          render json: {error: 0, message: 'Message Sent!'}
        else
          render json: {error: 1, message: 'Failed to send.'}
        end
      end
    end
  end

  def upload_attachment
    if request.xhr?
      results = []
      begin
        params[:attachments].each do |file|
          name = "#{Time.now.to_i}-#{file.original_filename}".gsub(' ', '_')
          directory = 'public/attachments/uploaded'
          path = File.join(directory, name)
          results << path if File.open(path, "wb") { |f| f.write(file.read) }
        end
        render json: {error: nil, message: 'Success', data: results.to_json}
      rescue => e
        render json: {error: "#{e}", message: "#{e}"}
      end
    end
  end

  def process_campaign_diagram
    render layout: false
  end

  protected
  def get_filter_time(time)
    from_day = time.days.ago
    broken_down = :day
    case time
    when TWENTY_FOUR_HOURS
      broken_down = :hour
    when SEVEN_DAYS_BY_HOURS
      broken_down = :hour
      from_day = 7.days.ago
    end
    return broken_down, from_day
  end
end
