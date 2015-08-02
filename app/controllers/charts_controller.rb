class ChartsController < ApplicationController
  before_filter :authenticate_user!
  DEFAULT = 2
  CUSTOM = 3

  def countries
    type_time = params[:day_id].to_i
    country_ids = []
    @series = []
    
    broken_down, from_day = get_filter_time(type_time)
    @countries= SummaryListen.get_countries_report_with_title.page(params[:page]).per(2)
    @countries.each do |country|
      country_ids << country.country_id
      data_table = GoogleVisualr::DataTable.new
      # Add Column Headers
      data_table.new_column('string', 'Date' )
      data_table.new_column('number', 'Minutes')

      # Add Rows and Values
      value = SummaryListen.get_report_for_country(country.country_id, {broken_down_by: broken_down, from_date: from_day})
      rows = get_data_point(value, broken_down)
      data_table.add_rows(rows)
      options = { width: 850, height: 200, title: country.title}
      @series << GoogleVisualr::Interactive::LineChart.new(data_table, options)
    end

    @opt_selected = params[:day_id].to_i if params[:day_id].present?
    render_common_default_charts(@series, country_ids, "countries", 1)
  end

  def load_gateways_or_dids_for_select 
    type_time = params[:day_id].to_i
    broken_down, from_day = get_filter_time(type_time)
    if params[:country_id].present?
      @country = DataGroupCountry.find_by_id params[:country_id]
      options = {broken_down_by: broken_down, from_date: from_day }
      @stations_filter = @country.data_gateways #SummaryListen.get_report_for_gateway(@country.id, options).map{|x| [x.title, x.obj_id]}.uniq if @country
      if params[:station_id].present?
        @station = DataGateway.find(params[:station_id])
        @dids_filter = @station.data_entryways #SummaryListen.get_report_for_gateway(@station.id, options).map{|x| [x.title, x.obj_id]}.uniq if @station
        @did = DataEntryway.where(did_e164: params[:did_id]).first if params[:did_id].present?
      end
    end
    @countries_filter = SummaryListen.get_countries_report_with_title
    render :partial => "charts/filter"
  end

  def stations
    type_time = params[:day_id].to_i
    station_ids = []
    @series = []

    broken_down, from_day = get_filter_time(type_time)
    data = SummaryListen.get_report_for_gateway(params[:country_id], 
      options = {broken_down_by: broken_down, from_date: from_day },
      current_user.aggregate_customs.only_gateways.map(&:removable_id),current_user.aggregate_customs.only_entryways.map(&:removable_id))
    data = data.group_by(&:obj_id)
    data.each do |station, value|
      data_table = GoogleVisualr::DataTable.new
      # Add Column Headers
      data_table.new_column('string', 'Date' )
      data_table.new_column('number', 'Minutes')
      country_name = DataGroupCountry.find_by_id(params[:country_id]).title
      case value.first.obj_type.to_i
      when SummaryListen::GATEWAY
        station_ids << [value.first.obj_id, params[:country_id]].join("__")
        title = [value.first.title, country_name].join(" - ")
      when SummaryListen::ENTRYWAY
        gateway_id = DataEntryway.find_by_id(value.first.obj_id).gateway_id
        station_ids << [value.first.obj_id, gateway_id, params[:country_id]].join("__")
        gateway_name = DataGateway.find_by_id(gateway_id).title
        title = [value.first.title, gateway_name, country_name].join(" - ")
      end
      rows = get_data_point(value, broken_down)
      data_table.add_rows(rows)
      options = { width: 830, height: 200, title: title}
      @series << GoogleVisualr::Interactive::LineChart.new(data_table, options)
    end

    level = 2
    tab = params[:kind].to_i
    case tab
    when DEFAULT
      render_common_default_charts(@series, station_ids, "stations", level)
    when CUSTOM
      render_child_custom_charts(@series, station_ids, "stations", level)
    end
  end

  # entryway
  def channels
    type_time = params[:day_id].to_i
    channel_ids = []
    @series = []

    broken_down, from_day = get_filter_time(type_time)
    data = SummaryListen.get_report_for_gateway(params[:gateway_id],
      options = {broken_down_by: broken_down, from_date: from_day},
      current_user.aggregate_customs.only_entryways.map(&:removable_id))
    data = data.group_by(&:obj_id)
    data.each do |station, value|
      data_table = GoogleVisualr::DataTable.new
      country_id = value.first.country_id
      channel_ids << [value.first.obj_id, params[:gateway_id], country_id].join("__")
      # Add Column Headers
      data_table.new_column('string', 'Date' )
      data_table.new_column('number', 'Minutes')

      rows = get_data_point(value, broken_down)
      # Add Rows and Values
      data_table.add_rows(rows)
      country_name = DataGroupCountry.find_by_id(country_id).title
      gateway_name = DataGateway.find_by_id(params[:gateway_id]).title

      options = { width: 790, height: 200, title: [value.first.title, gateway_name, country_name].join(" - ")}
      @series << GoogleVisualr::Interactive::LineChart.new(data_table, options)
    end
    tab = params[:kind].to_i
    if tab == DEFAULT
      render_common_default_charts(@series, channel_ids, "channels", 3)
    elsif tab == CUSTOM
      render_child_custom_charts(@series, channel_ids, "channels", 3)
    end
  end

  def aggregate
    kind = params[:kind].to_i
    type_time = params[:day_id].to_i
    broken_down, from_day = get_filter_time(type_time)
    data = if kind == CUSTOM
      current_user.get_aggregate_custom_chart({broken_down_by: broken_down}, from_day)
    else 
      SummaryListen.get_aggregate_default({broken_down_by: broken_down}, from_day)
    end
    @series = []
    data_table = GoogleVisualr::DataTable.new
    # Add Column Headers
    data_table.new_column('string', 'Date' )
    data_table.new_column('number', 'Minutes')

    rows = data.map {|aggr| [Date.parse(aggr.called_date).strftime("%a %d"), aggr.total_minutes.to_f.round(2)]}
    # Add Rows and Values
    data_table.add_rows(rows)

    options = { width: 850, height: 200, title: "Aggregate"}
    @series << GoogleVisualr::Interactive::LineChart.new(data_table, options)
    @opt_selected = params[:day_id].to_i if params[:day_id].present?
    render :partial => "aggregate", locals: { series: @series}
  end

  def load_custom
    type_time = params[:day_id].to_i
    broken_down, from_day = get_filter_time(type_time)
    country_ids = []
    @series = []
    levels = {}
    m_types = {}
    from_day = Date.today-30
    levels_types = {}
    @countries= Kaminari.paginate_array(current_user.get_objects_custom_aggregate_report).page(params[:page]).per(2)
    @countries.each do |obj|
      data_table = GoogleVisualr::DataTable.new
      # Add Column Headers
      data_table.new_column('string', 'Date' )
      data_table.new_column('number', 'Minutes')
      name = ""
      # Add Rows and Values
      case obj.obj_type.to_i 
      when SummaryListen::COUNTRY
        value = SummaryListen.get_report_for_country(obj.obj_id, {broken_down_by: broken_down, from_date: from_day})
        levels[obj.obj_id.to_s] = 1
        country_ids << obj.obj_id.to_s
        m_types[obj.obj_type] = "countries"
        levels_types[obj.obj_id.to_s] = obj.obj_type
        name = obj.obj_name
      when SummaryListen::GATEWAY
        value = SummaryListen.get_report_by_country_and_gateway(obj.country_id, obj.obj_id, {broken_down_by: broken_down, from_date: from_day})
        ids = [obj.obj_id, obj.country_id].join("_")
        m_types[obj.obj_type] = "stations"
        levels[ids] = 2
        country_ids << ids
        country_name = DataGroupCountry.find_by_id(obj.country_id).title
        levels_types[ids] = obj.obj_type
        name = [obj.obj_name, country_name].join(" - ")
      when SummaryListen::ENTRYWAY
        value = SummaryListen.get_report_by_entryway_id(obj.obj_id, {broken_down_by: broken_down, from_date: from_day})
        m_types[obj.obj_type] = "channels"
        ids = [obj.obj_id, obj.country_id, value.first.gateway_id].join("_")
        levels[ids] = 3
        country_ids << ids
        levels_types[ids] = obj.obj_type
        #[value.first.entryway_id, value.first.gateway_id, value.first.country_id]
        country_name = DataGroupCountry.find_by_id(value.first.country_id).title
        gateway_name = DataGateway.find_by_id(value.first.gateway_id).title
        name = [obj.obj_name, gateway_name, country_name].join(" - ")
      end

      rows = get_data_point(value, broken_down)
      data_table.add_rows(rows)
      options = { width: 850, height: 200, title: name}
      @series << GoogleVisualr::Interactive::LineChart.new(data_table, options)
    end

    @opt_selected = params[:day_id].to_i if params[:day_id].present?

    @countries_filter = SummaryListen.get_countries_report_with_title

    render_common_custom_charts(@series, country_ids, m_types, levels, levels_types)
  end

  protected
  def render_common_default_charts(series, data, level_name = nil, level = nil)
    render :partial => "common_default_charts", locals: { series: series, data: data, :level_name => level_name, :level => level }
  end

  def render_common_custom_charts(series, data, level_name = nil, level = nil, levels_types = {})
    render :partial => "common_custom_charts", locals: { series: series, data: data, :level_name => level_name, :level => level, :levels_types => levels_types }
  end
  def render_child_custom_charts(series, data, level_name = nil, level = nil)
    render :partial => "child_custom_charts", locals: { series: series, data: data, :level_name => level_name, :level => level }
  end

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
   
  def get_data_point(data, broken_down)
    if broken_down == :hour
      data.map do |obj_listener| 
        called_hour = [[obj_listener.hour, "h"].join, obj_listener.date.strftime("%a %d")].join(" - ")
        [called_hour, convert_seconds_to_minutes(obj_listener.total_second)]
      end
    else
       data.map {|obj_listener| [obj_listener.date.strftime("%a %d"), convert_seconds_to_minutes(obj_listener.total_second)]}
    end
  end

end
