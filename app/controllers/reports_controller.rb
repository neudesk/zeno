class ReportsController < ApplicationController
  before_filter :authenticate_user!
  def index
      if current_user.stations.present?
      @gateway_id = params[:gateway_id] || params[:station_id]
      @gateway_id = current_user.stations[0].id if current_user.stations.length == 1
      @no_of_stations = current_user.stations.length
      @all_current_user_did = DataEntryway.where("gateway_id = '#{@gateway_id}' and is_deleted = false").select("data_entryway.did_e164, data_entryway.id").order(:did_e164)

      @stations = current_user.stations
      @q = @stations.search(params[:q])
      @stations = @q.result(distinct: true).page(params[:page]).per(15)
      if @stations.total_pages < params[:page].to_i
        params[:page] = 1
        @stations = @q.result(distinct: true).page(params[:page]).per(15)
      end
      @page = params[:page] || 1

      params[:station_id] = @stations.first.id if @stations.size == 1

      @station = DataGateway.find_by_id(params[:station_id])
      if @station.present?
        result = reports_data(0,gateway_id = @station.id)
      else
        result = reports_data(0)
      end
      raw_data = []

      dt = DateTime.now
      (1..dt.at_end_of_month.day.to_i).each do |d|
        currentdt = Date.parse("#{dt.strftime('%Y')}-#{dt.strftime('%b')}-#{d.to_s}")
        data = result.select{|x| x[0].strftime('%-d') == d.to_s}[0]
        if data.present?
          raw_data << [ parseme(data[0]), data[1], data[2], data[3], data[4]]
          else
            raw_data << [{:month => currentdt.strftime('%b'),
              :day => currentdt.strftime('%d'),
              :year => currentdt.strftime('%Y'),
              :dayinwords => currentdt.strftime('%a')},
              0, 0, 0, 0]
            end
          end
      @result = raw_data
      @labels = @result.collect {|x| x[0][:day]}
      @new_users_values = @result.collect {|x| x[1]}
      @active_users_values = @result.collect {|x| x[2]}
      @sessions_values = @result.collect {|x| x[3]}
      @minutes_values = @result.collect {|x| x[4]}
      @totals = [@new_users_values.sum, @active_users_values.sum, @sessions_values.sum, @minutes_values.sum]
    end
  end
  
  
  def render_graphs
    @station = DataGateway.find_by_id(params[:station_id])
    gateway_id = params[:station_id]
    gateway_id = current_user.stations[0].id if current_user.stations.length == 1
    number = (params[:month] == '') ? 0 : params[:month].to_i
    entryway_id = (params[:entryway_id].to_i == 0)? nil : params[:entryway_id]
    result = reports_data(number, gateway_id,entryway_id)
   
    raw_data = []
    dt = number.month.ago
    (1..dt.at_end_of_month.day.to_i).each do |d|
      currentdt = Date.parse("#{dt.strftime('%Y')}-#{dt.strftime('%b')}-#{d.to_s}")
      if result.present?
        data = result.select{|x| x[0].strftime('%-d') == d.to_s}[0]
        if data.present?
          raw_data << [ parseme(data[0]), data[1], data[2], data[3], data[4]]
        else
          raw_data << [{:month => currentdt.strftime('%b'),
            :day => currentdt.strftime('%d'),
            :year => currentdt.strftime('%Y'),
            :dayinwords => currentdt.strftime('%a')},
            0, 0, 0, 0]
          end
        else
          raw_data << [{:month => currentdt.strftime('%b'),
            :day => currentdt.strftime('%d'),
            :year => currentdt.strftime('%Y'),
            :dayinwords => currentdt.strftime('%a')},
            0, 0, 0, 0]
          end
      end

    @result = raw_data
    @labels = @result.collect {|x| x[0][:day]}
    @js_labels = @labels.join(",")

    @new_users_values = @result.collect {|x| x[1]}
    @js_new_users_values = @new_users_values.join(",")

    @active_users_values = @result.collect {|x| x[2]}
    @js_active_users_values = @active_users_values.join(",")

    @sessions_values = @result.collect {|x| x[3]}
    @js_sessions_values = @sessions_values.join(",")

    @minutes_values = @result.collect {|x| x[4]}
    @js_minutes_values = @minutes_values.join(",")

    @totals = [@new_users_values.sum, @active_users_values.sum, @sessions_values.sum, @minutes_values.sum]
    @js_totals = @totals.join(",")
    # render :json => @result
  end

  def parseme(datestring = nil)
    unless datestring.nil?
      dt = Date.parse(datestring.to_s)
      return {:month => dt.strftime('%b'),
              :day => dt.strftime('%d'),
              :year => dt.strftime('%Y'),
              :dayinwords => dt.strftime('%a')}
    end
  end

  def get_graphs
    gateway_id = params[:gateway_id]
    gateway_id = current_user.stations[0].id if current_user.stations.length == 1
    number = (params[:month] == "") ? 0 : params[:month].to_i
    entryway_id = (params[:entryway_id].to_i == 0)? nil : params[:entryway_id]
    reports =  reports_data(number, gateway_id,entryway_id)
    total_minutes = total_minutes_chart(reports)
    minutes = DataListenerAtGateway.get_total_minutes(current_user, gateway_id)
    month = number.month.ago
    render :partial => "reports/graphs", :locals => {:total_minutes => total_minutes, :reports => reports,:month => month, :minutes => minutes }
    # render :json => reports
  end

  def total_minutes_chart(reports)
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Day')
    data_table.new_column('number', 'Minutes')
    rows = []
    reports.each do |rep|
      rows<< [rep[0].strftime("%d").to_s,rep[4]]
    end
    data_table.add_rows(rows)
    opts = { width: 940,
      height: 250,
      title: 'Total Minutes',
      :titleTextStyle => {color: '#11515E', fontSize: '14', bold: true},
      colors: ["#AE94D1"],
      :chartArea => {:left => 70, :top => 40, :width => 770},
      areaOpacity: 1.0, hAxis: {slantedTextAngle: 45, slantedText: true}}
    GoogleVisualr::Interactive::AreaChart.new(data_table, opts)
  end
  
  def reports_data(number,gateway_id = nil,entryway_id = nil)
    @totals = []
    begin
      year = number.month.ago.beginning_of_month.strftime('%Y')
      month = number.month.ago.end_of_month.strftime('%m')
      days = Time.days_in_month(number.month.ago.strftime('%m').to_i, year=number.month.ago.strftime('%Y').to_i)
      sql_result = nil

      start_date = Date.parse("#{year}-#{month}-#{01}")
      end_date = Date.parse("#{year}-#{month}-#{days}")
      
      if end_date.strftime("%m") >= "01" && end_date.strftime("%m") < "07"
        entryway_id.present? ? table_name = "report_by_did_#{end_date.strftime('%Y')}_1" : table_name = "report_#{end_date.strftime('%Y')}_1"
      else
        entryway_id.present? ? table_name = "report_by_did_#{end_date.strftime('%Y')}_2" : table_name = "report_#{end_date.strftime('%Y')}_2"
      end
      if ActiveRecord::Base.connection.tables.include?(table_name)
        if gateway_id.present? && entryway_id.blank?
          sql = " SELECT DATE(report_date),new_users,active_users,sessions,total_minutes FROM #{table_name} WHERE report_date >= '#{start_date}' 
            AND  report_date <= '#{end_date}' AND gateway_id = '#{gateway_id}'"
        elsif entryway_id.present? 
          sql = " SELECT DATE(report_date),new_users,active_users,sessions,total_minutes FROM #{table_name} WHERE report_date >= '#{start_date}' 
            AND  report_date <= '#{end_date}' AND entryway_id = '#{entryway_id}'"
        else
          if current_user.is_marketer?
            sql = " SELECT DATE(report_date),new_users,active_users,sessions,total_minutes FROM #{table_name} WHERE report_date >= '#{start_date}' 
            AND  report_date <= '#{end_date}' AND gateway_id IS NULL"
          else
            gateway_ids = current_user.stations.map(&:id)
            sql = " SELECT DATE(report_date) as dates,sum(new_users),sum(active_users),sum(sessions),sum(total_minutes) FROM #{table_name} WHERE report_date >= '#{start_date}' 
            AND  report_date <= '#{end_date}' AND gateway_id IN (#{gateway_ids.join(',')}) group by dates "
          end

        end
        sql_result =  ActiveRecord::Base.connection.execute(sql).to_a
        # total_new_users = sql_result.map { |r| r[1]}.inject(:+)
        # total_active_users = sql_result.map { |r| r[2]}.inject(:+)
        # total_sessions = sql_result.map { |r| r[3]}.inject(:+)
        # total_minutes = sql_result.map { |r| r[4]}.inject(:+)
        if sql_result.present?
          @totals  << [sql_result.collect {|x| x[1]}.sum,
                       sql_result.collect {|x| x[2]}.sum,
                       sql_result.collect {|x| x[3]}.sum,
                       sql_result.collect {|x| x[4]}.sum ]
        else
          @totals  << [0,0,0,0]
        end
      end
      sql_result
    rescue => error
      error.message
    end
  end

  def did_reports
    redirect_to :root
    entryway = DataEntryway.select([:title, :id, :gateway_id, :did_e164]).order('title')
    @prov_list = []
    providers = []
    entryway.each do |ew|
      title = ew.title.split('-')[0].strip
      if !@prov_list.include? title
        @prov_list << title
        providers << {:title => title,
                      :total_did => entryway.where(['TRIM(LOWER(title)) LIKE ?', "%#{title.downcase.strip}%"]).count,
                      :used_did => entryway.where(['TRIM(LOWER(title)) LIKE ?', "%#{title.downcase.strip}%"]).where("gateway_id IS NOT NULL").count}
      end
    end
    @country = DataGroupCountry.select([:id, :title]).order('title')
    @rcas = DataGroupRca.select([:id, :title]).order('title')
    @station = DataGateway.select([:id, :title]).order('title')
    @providers = Kaminari.paginate_array(providers).page(params[:page]).per(15)
    # render :json => @providers
  end

  def did_search_reports
    entryway = DataEntryway.select([:title, :id, :gateway_id, :did_e164]).order('title')
    @prov_list = []
    entryway.each do |ew|
      title = ew.title.split('-')[0].strip
      @prov_list << title if !@prov_list.include? title
    end
    @country = DataGroupCountry.select([:id, :title]).order('title')
    @rcas = DataGroupRca.select([:id, :title]).order('title')
    @station = DataGateway.select([:id, :title]).order('title')
    @result = []
    if params[:provider].present?
      @sel_provider = params[:provider]
      entryways = entryway.where(['TRIM(LOWER(title)) LIKE ?', "%#{params[:provider].downcase.strip}%"])
      prov_list = []
      entryways.each do |e|
        title = e.title.split('-')[0].strip
        entryways_by_title = entryways.where(['TRIM(LOWER(title)) LIKE ?', "%#{title.downcase.strip}%"])
        if !prov_list.include? title
          prov_list << title
          @result << {:title => title,
                      :dids => entryways_by_title.map {|x| x.did_e164},
                      :total_dids => entryways_by_title.count}
        end
      end
    end
    if params[:station].present?
      @sel_station = params[:station]
      entryways = entryway.where(:gateway_id => params[:station])
      prov_list = []
      entryways.each do |e|
        title = e.title.split('-')[0].strip
        entryways_by_title = entryways.where(['TRIM(LOWER(title)) LIKE ?', "%#{title.downcase.strip}%"])
        if !prov_list.include? title
          prov_list << title
          @result << {:title => title,
                      :dids => entryways_by_title.map {|x| x.did_e164},
                      :total_dids => entryways_by_title.count}
        end
      end
    end
    if params[:country]
      @sel_country = params[:country]
      entryways = entryway.where(:country_id => params[:country])
      prov_list = []
      entryways.each do |e|
        title = e.title.split('-')[0].strip
        entryways_by_title = entryways.where(['TRIM(LOWER(title)) LIKE ?', "%#{title.downcase.strip}%"])
        if !prov_list.include? title
          prov_list << title
          @result << {:title => title,
                      :dids => entryways_by_title.map {|x| x.did_e164},
                      :total_dids => entryways_by_title.count}
        end
      end
    end
    if params[:rca]
      @sel_rca = params[:rca]
      entryways = entryway.where("gateway_id IS NOT NULL")
      gateway = DataGateway.select([:id, :rca_id]).where(:rca_id => params[:rca]).pluck(:id)
      prov_list = []
      entryways.each do |e|
        if gateway.include? e.gateway_id
          title = e.title.split('-')[0].strip
          entryways_by_title = entryways.where(['TRIM(LOWER(title)) LIKE ?', "%#{title.downcase.strip}%"])
          if !prov_list.include? title
            prov_list << title
            @result << {:title => title,
                        :dids => entryways_by_title.map {|x| x.did_e164},
                        :total_dids => entryways_by_title.count}
          end
        end
      end
    end
    @result = Kaminari.paginate_array(@result).page(params[:page]).per(3)
    # render :json => params
  end
  
end
