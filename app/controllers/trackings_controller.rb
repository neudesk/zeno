class TrackingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :restrict_admin_only

  PER_PAGE = 10

  def did

    if current_user.is_marketer?
      @all_current_user_did = DataEntryway.select("data_entryway.did_e164, data_entryway.id").order(:did_e164)
    else
      @all_current_user_did = DataEntryway.with_rca(current_user).select("data_entryway.did_e164, data_entryway.id").order(:did_e164)
    end

    @current_day = DateTime.now
    @seven_days_back = @current_day - 7
    @previous_day = @current_day - 1
    @next_1_day = @current_day + 1
    @next_2_day = @current_day + 2

    @did_id_param  = params[:did_id] || ""
    @time_param = params[:time] || 1

    @all_current_user_did_ids = @all_current_user_did.map{ |entry| entry.id }


    if @did_id_param == ""
      @did_arr_arg = @all_current_user_did_ids
    else
      @did_arr_arg = [params[:did_id]]
    end


    @seven_days_back_records  = DataEntryway.get_selected_tracking_did(current_user,  @did_arr_arg, 7.day.ago.to_date, Date.today, @time_param)
    @seven_days_back_records = @seven_days_back_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


    @previous_day_records  = DataEntryway.get_selected_tracking_did(current_user,  @did_arr_arg, 1.day.ago.to_date, 1.day.ago.to_date, @time_param)
    @previous_day_records = @previous_day_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


    @current_day_records  = DataEntryway.get_selected_tracking_did(current_user,  @did_arr_arg, Date.today, Date.today, @time_param)
    @current_day_records = @current_day_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


    @next_two_days_records  = DataEntryway.get_selected_tracking_did(current_user,  @did_arr_arg, 1.day.since.to_date, 2.day.since.to_date, @time_param)
    @next_two_days_records = @next_two_days_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


    data_table = GoogleVisualr::DataTable.new
    # Add Column Headers
    data_table.new_column('string', 'Date' )
    data_table.new_column('number', 'Minutes')

    @chart_title = "DID"

    if @did_id_param == ""
      @seven_days_back_agg_records  = DataEntryway.get_aggregate_tracking_did(current_user, 7.day.ago.to_date, Date.today, @time_param)

      @previous_day_agg_records  = DataEntryway.get_aggregate_tracking_did(current_user, 1.day.ago.to_date, 1.day.ago.to_date, @time_param)



      @current_day_agg_records  = DataEntryway.get_aggregate_tracking_did(current_user,Date.today, Date.today, @time_param)


      @next_two_days_agg_records  = DataEntryway.get_aggregate_tracking_did(current_user, 1.day.since.to_date, 2.day.since.to_date, @time_param)

      rows = [["#{@seven_days_back.strftime("%b %d")} -> #{@current_day.strftime("%b %d")}",@seven_days_back_agg_records[0].total_minutes.to_f], ["#{@previous_day.strftime("%b %d")}", @previous_day_agg_records[0].total_minutes.to_f], ["#{@current_day.strftime("%b %d")}",@current_day_agg_records[0].total_minutes.to_f], ["#{@next_1_day.strftime("%b %d")} -> #{@next_2_day.strftime("%b %d")}",@next_two_days_agg_records[0].total_minutes.to_f]]

    else
      @chart_title = "DID: #{@seven_days_back_records[0].did}"
      rows = [["#{@seven_days_back.strftime("%b %d")} -> #{@current_day.strftime("%b %d")}", @seven_days_back_records[0].total_minutes.to_f], ["#{@previous_day.strftime("%b %d")}", @previous_day_records[0].total_minutes.to_f], ["#{@current_day.strftime("%b %d")}", @current_day_records[0].total_minutes.to_f], ["#{@next_1_day.strftime("%b %d")} -> #{@next_2_day.strftime("%b %d")}", @next_two_days_records[0].total_minutes.to_f]]
    end

    # Add Rows and Values
    data_table.add_rows(rows)

    options = { width: 850, height: 200, title: @chart_title}
    @chart =  GoogleVisualr::Interactive::ColumnChart.new(data_table, options)
  end

  def stations

    if current_user.is_marketer?
      @all_current_user_gateways = DataGateway.select("data_gateway.title, data_gateway.id").order(:title)
    else
      @all_current_user_gateways = DataGateway.with_rca(current_user).select("data_gateway.title, data_gateway.id").order(:title)
    end

    @current_day = DateTime.now
    @seven_days_back = @current_day - 7
    @previous_day = @current_day - 1
    @next_1_day = @current_day + 1
    @next_2_day = @current_day + 2

    @gateway_id_param  = params[:gateway_id] || ""
    @time_param = params[:time] || 1

    @all_current_user_gateway_ids = @all_current_user_gateways.map{ |gateway| gateway.id }

    if @gateway_id_param == ""
      @gateway_id_arr_arg = @all_current_user_gateway_ids
    else
      @gateway_id_arr_arg = [params[:gateway_id]]
    end


    #query DIDs from selected gateway ids
    @all_current_user_did = DataEntryway.where(:gateway_id => @gateway_id_arr_arg).select("data_entryway.did_e164, data_entryway.id").order(:did_e164)

    @did_arr_arg = @all_current_user_did.map { |entryway| entryway.id }

    @seven_days_back_did_records  = DataEntryway.get_selected_tracking_did(current_user,  @did_arr_arg, 7.day.ago.to_date, Date.today, @time_param)
    @seven_days_back_did_records = @seven_days_back_did_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


    @previous_day_did_records  = DataEntryway.get_selected_tracking_did(current_user,  @did_arr_arg, 1.day.ago.to_date, 1.day.ago.to_date, @time_param)
    @previous_day_did_records = @previous_day_did_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


    @current_day_did_records  = DataEntryway.get_selected_tracking_did(current_user,  @did_arr_arg, Date.today, Date.today, @time_param)
    @current_day_did_records = @current_day_did_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


    @next_two_days_did_records  = DataEntryway.get_selected_tracking_did(current_user,  @did_arr_arg, 1.day.since.to_date, 2.day.since.to_date, @time_param)
    @next_two_days_did_records = @next_two_days_did_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


    data_table = GoogleVisualr::DataTable.new
    # Add Column Headers
    data_table.new_column('string', 'Date' )
    data_table.new_column('number', 'Minutes')

    @chart_title = "Stations"

    if @gateway_id_param == ""
      @seven_days_back_agg_records  = DataGateway.get_aggregate_tracking_stations(current_user, 7.day.ago.to_date, Date.today, @time_param)

      @previous_day_agg_records  = DataGateway.get_aggregate_tracking_stations(current_user, 1.day.ago.to_date, 1.day.ago.to_date, @time_param)


      @current_day_agg_records  = DataGateway.get_aggregate_tracking_stations(current_user,Date.today, Date.today, @time_param)


      @next_two_days_agg_records  = DataGateway.get_aggregate_tracking_stations(current_user, 1.day.since.to_date, 2.day.since.to_date, @time_param)

      rows = [["#{@seven_days_back.strftime("%b %d")} -> #{@current_day.strftime("%b %d")}",@seven_days_back_agg_records[0].total_minutes.to_f], ["#{@previous_day.strftime("%b %d")}", @previous_day_agg_records[0].total_minutes.to_f], ["#{@current_day.strftime("%b %d")}",@current_day_agg_records[0].total_minutes.to_f], ["#{@next_1_day.strftime("%b %d")} -> #{@next_2_day.strftime("%b %d")}",@next_two_days_agg_records[0].total_minutes.to_f]]

    else

      @seven_days_back_records  = DataGateway.get_selected_tracking_stations(current_user,  @gateway_id_arr_arg, 7.day.ago.to_date, Date.today, @time_param)
      @seven_days_back_records = @seven_days_back_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


      @previous_day_records  = DataGateway.get_selected_tracking_stations(current_user,  @gateway_id_arr_arg, 1.day.ago.to_date, 1.day.ago.to_date, @time_param)
      @previous_day_records = @previous_day_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


      @current_day_records  = DataGateway.get_selected_tracking_stations(current_user,  @gateway_id_arr_arg, Date.today, Date.today, @time_param)
      @current_day_records = @current_day_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


      @next_two_days_records  = DataGateway.get_selected_tracking_stations(current_user,  @gateway_id_arr_arg, 1.day.since.to_date, 2.day.since.to_date, @time_param)
      @next_two_days_records = @next_two_days_records.page(params[:page]).per(params[:per_page] || PER_PAGE)

      @chart_title = "Station: #{@seven_days_back_records[0].title}"
      rows = [["#{@seven_days_back.strftime("%b %d")} -> #{@current_day.strftime("%b %d")}", @seven_days_back_records[0].total_minutes.to_f], ["#{@previous_day.strftime("%b %d")}", @previous_day_records[0].total_minutes.to_f], ["#{@current_day.strftime("%b %d")}", @current_day_records[0].total_minutes.to_f], ["#{@next_1_day.strftime("%b %d")} -> #{@next_2_day.strftime("%b %d")}", @next_two_days_records[0].total_minutes.to_f]]
    end

    # Add Rows and Values
    data_table.add_rows(rows)

    options = { width: 850, height: 200, title: @chart_title}
    @chart =  GoogleVisualr::Interactive::ColumnChart.new(data_table, options)

  end

  def country

    @all_countries = DataGroupCountry.select("data_group_country.title, data_group_country.id").order(:title)

    @current_day = DateTime.now
    @seven_days_back = @current_day - 7
    @previous_day = @current_day - 1
    @next_1_day = @current_day + 1
    @next_2_day = @current_day + 2

    @country_id_param  = params[:country_id] || ""
    @time_param = params[:time] || 1

    @all_country_ids = @all_countries.map{ |country| country.id }

    if @country_id_param == ""
      @country_id_arr_arg = @all_country_ids
    else
      @country_id_arr_arg = [params[:country_id]]
    end


    #query DIDs from selected gateway ids
    @all_current_user_did = DataEntryway.where(:country_id => @country_id_arr_arg).select("data_entryway.did_e164, data_entryway.id").order(:did_e164)

    @did_arr_arg = @all_current_user_did.map { |entryway| entryway.id }

    @seven_days_back_did_records  = DataEntryway.get_selected_tracking_did(current_user,  @did_arr_arg, 7.day.ago.to_date, Date.today, @time_param)
    @seven_days_back_did_records = @seven_days_back_did_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


    @previous_day_did_records  = DataEntryway.get_selected_tracking_did(current_user,  @did_arr_arg, 1.day.ago.to_date, 1.day.ago.to_date, @time_param)
    @previous_day_did_records = @previous_day_did_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


    @current_day_did_records  = DataEntryway.get_selected_tracking_did(current_user,  @did_arr_arg, Date.today, Date.today, @time_param)
    @current_day_did_records = @current_day_did_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


    @next_two_days_did_records  = DataEntryway.get_selected_tracking_did(current_user,  @did_arr_arg, 1.day.since.to_date, 2.day.since.to_date, @time_param)
    @next_two_days_did_records = @next_two_days_did_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


    data_table = GoogleVisualr::DataTable.new
    # Add Column Headers
    data_table.new_column('string', 'Date' )
    data_table.new_column('number', 'Minutes')

    @chart_title = "Countries"

    if @country_id_param == ""
      @seven_days_back_agg_records  = DataGroupCountry.get_aggregate_tracking_country( 7.day.ago.to_date, Date.today, @time_param)

      @previous_day_agg_records  = DataGroupCountry.get_aggregate_tracking_country( 1.day.ago.to_date, 1.day.ago.to_date, @time_param)


      @current_day_agg_records  = DataGroupCountry.get_aggregate_tracking_country(Date.today, Date.today, @time_param)


      @next_two_days_agg_records  = DataGroupCountry.get_aggregate_tracking_country( 1.day.since.to_date, 2.day.since.to_date, @time_param)

      rows = [["#{@seven_days_back.strftime("%b %d")} -> #{@current_day.strftime("%b %d")}",@seven_days_back_agg_records[0].total_minutes.to_f], ["#{@previous_day.strftime("%b %d")}", @previous_day_agg_records[0].total_minutes.to_f], ["#{@current_day.strftime("%b %d")}",@current_day_agg_records[0].total_minutes.to_f], ["#{@next_1_day.strftime("%b %d")} -> #{@next_2_day.strftime("%b %d")}",@next_two_days_agg_records[0].total_minutes.to_f]]

    else

      @seven_days_back_records  = DataGroupCountry.get_selected_tracking_country(  @country_id_arr_arg, 7.day.ago.to_date, Date.today, @time_param)
      @seven_days_back_records = @seven_days_back_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


      @previous_day_records  = DataGroupCountry.get_selected_tracking_country(  @country_id_arr_arg, 1.day.ago.to_date, 1.day.ago.to_date, @time_param)
      @previous_day_records = @previous_day_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


      @current_day_records  = DataGroupCountry.get_selected_tracking_country(  @country_id_arr_arg, Date.today, Date.today, @time_param)
      @current_day_records = @current_day_records.page(params[:page]).per(params[:per_page] || PER_PAGE)


      @next_two_days_records  = DataGroupCountry.get_selected_tracking_country(  @country_id_arr_arg, 1.day.since.to_date, 2.day.since.to_date, @time_param)
      @next_two_days_records = @next_two_days_records.page(params[:page]).per(params[:per_page] || PER_PAGE)

      @chart_title = "Country: #{@seven_days_back_records[0].country_name}"
      rows = [["#{@seven_days_back.strftime("%b %d")} -> #{@current_day.strftime("%b %d")}", @seven_days_back_records[0].total_minutes.to_f], ["#{@previous_day.strftime("%b %d")}", @previous_day_records[0].total_minutes.to_f], ["#{@current_day.strftime("%b %d")}", @current_day_records[0].total_minutes.to_f], ["#{@next_1_day.strftime("%b %d")} -> #{@next_2_day.strftime("%b %d")}", @next_two_days_records[0].total_minutes.to_f]]
    end

    # Add Rows and Values
    data_table.add_rows(rows)

    options = { width: 850, height: 200, title: @chart_title}
    @chart =  GoogleVisualr::Interactive::ColumnChart.new(data_table, options)

  end

  def users
    @activity_query = params[:activity_query]
    @activity_type = params[:activity_type]
    where = ''
    if @activity_query.present?
      gateway = DataGateway.where("title LIKE '%#{@activity_query}%'")
      gateway_id = gateway.first.id if gateway.present?
      entryway = DataEntryway.where("did_e164 LIKE '%#{@activity_query}%'")
      entryway_id = entryway.first.id if entryway.present?
      if gateway_id.present? or entryway_id.present?
        where = "(trackable_id = #{gateway_id.present? ? gateway_id : entryway_id} OR trackable_title LIKE '%#{@activity_query}%' OR user_title LIKE '%#{@activity_query}%' OR sec_trackable_title LIKE '#{@activity_query}%')"
      else
        where = "(trackable_title LIKE '%#{@activity_query}%' OR user_title LIKE '%#{@activity_query}%' OR sec_trackable_title LIKE '#{@activity_query}%')"
      end
    end
    if @activity_type.present? and @activity_type != 'All'
      unless where.blank?
        where += ' AND '
      end
      case @activity_type
        when 'Login'
          where += "trackable_type LIKE 'User%' AND `key` LIKE 'user.login'"
        when 'Users Account'
          where += "trackable_type LIKE 'User%' AND `key` NOT LIKE 'user.login%'"
        when 'Content'
          where += "trackable_type LIKE 'DataContent' AND `key` NOT LIKE 'data_content.media_type'"
        when 'Gateway'
          where += "(trackable_type LIKE 'DataGateway' OR trackable_type LIKE 'DataGatewayConference')"
        when 'Data Groups'
          where += "(trackable_type LIKE 'DataGateway' OR trackable_type LIKE 'DataEntryway') AND (`key` LIKE 'data_gateway.grouping' OR `key` LIKE 'data_entryway.grouping' OR `key` LIKE 'data_gateway.delete_grouping' OR `key` LIKE 'data_entryway.delete_grouping')"
        when 'Data Taggings'
          where += "(trackable_type LIKE 'DataGateway' OR trackable_type LIKE 'DataContent') AND (`key` LIKE 'data_gateway.tagging' OR `key` LIKE 'data_content.tagging' OR `key` LIKE 'data_gateway.delete_tagging' OR `key` LIKE 'data_content.delete_tagging')"
        when 'Tool Request'
          where += "trackable_type LIKE 'StationTool' AND `key` LIKE 'station_tool.request_tool'"
        when 'Media Types'
          where += "trackable_type LIKE 'DataContent' AND `key` LIKE 'data_content.media_type'"
        when 'Reachout'
          where += "trackable_type LIKE 'ReachoutTabCampaign' "
        when 'Admin Settings'
          where += "trackable_type LIKE 'AdminSetting' "
        when 'Data Group RCA'
          where += "trackable_type LIKE 'DataGroupRca' "
        when 'Data Group RCA'
          where += "trackable_type LIKE 'DataGatewayNote' "
      end
    end
    if where.blank?
      @activities = PublicActivity::Activity.order("created_at desc").page(params[:page]).per(60)
    else
      @activities = PublicActivity::Activity.where(where).order("created_at desc").page(params[:page]).per(60)
    end
    # render :json => current_user
  end

end

# "Users Account","Data Groups and Tags","Media Types"