class NumericalReportsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_stations, :except => [:download]
  
  helper_method :sort_column, :sort_direction
  PER_PAGE = 10
  def top_listeners
    assigned_gateways = current_user.is_rca? ? DataGateway.with_rca(current_user) : DataGateway
    @gateways = assigned_gateways.all.map{|g| [g.title, g.id]}
    @reports = current_user.top_listeners({gateway_id: params[:gateway_id] || "",
                                           week: params[:week] || DateTime.now.cweek,
                                           sort: params[:sort],
                                           direction: params[:direction]})
                           .page(params[:page]).per(params[:per_page] || PER_PAGE)
  end

  def top_stations
    @reports = User.top_stations(current_user, {day: params[:day] || 1})
    @reports = Kaminari.paginate_array(@reports).page(params[:page]).per(PER_PAGE)
  end
  
  def anis_days_not_active
    assigned_gateways = current_user.is_rca? ? DataGateway.with_rca(current_user) : DataGateway
    @dids = assigned_gateways.joins(:data_entryways)
                                .select("data_entryway.id as id, data_entryway.did_e164 as did")
                                .map{|e| [e.did, e.id]}
    @category_type = params[:category_type] || 1
    @gateways = assigned_gateways.all.map{|g| [g.title, g.id]}
    @reports = current_user.anis_days_not_active({category_type: @category_type.to_i,
                                                                 gateway_id: params[:gateway_id],
                                                                 country_id: params[:country_id],
                                                                 callminutes: params[:callminutes],
                                                                 calldays: params[:calldays],
                                                                 nocalldays: params[:nocalldays],
                                                                 did: params[:did]})
    @countries = assigned_gateways.joins(:data_group_country)
                                   .select("data_group_country.id as id, data_group_country.title as title")
                                   .map{|e| [e.title, e.id]}.uniq
    @total_minutes = @reports.map{|r| r.minutes.to_i}.sum
    @reports = @reports.page(params[:page]).per(params[:per_page] || PER_PAGE)
  end

  def download
    data = current_user.export_anis_days_not_active(params)
    filename ="ANIs not active_#{Date.today.strftime('%d%b%y')}"
    respond_to do |format|
      format.csv { send_data data,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=#{filename}.csv"
      }
    end
    flash[:notice] = "Download complete!"
  end

  def rca_minutes
    @limit = params[:limit] || PER_PAGE
    @reports = SummaryListen.rca_reports
    @reports = Kaminari.paginate_array(@reports).page(params[:page]).per(@limit)
  end

  def country_minutes
    @limit = params[:limit] || PER_PAGE
    @reports = SummaryListen.rca_country_report
    @reports = Kaminari.paginate_array(@reports).page(params[:page]).per(@limit)
  end

  def average_time
    @limit = params[:limit] || PER_PAGE
    @time_per_users = SummaryListen.get_average_time_per_user.page(params[:page]).per(PER_PAGE)
    @average_countries = DataGroupCountry.country_aggregate_for_average_listening.page(params[:page]).per(PER_PAGE)
  end

  def minutes_divided_clec
    @limit = params[:limit] || PER_PAGE
    @reports = DataEntrywayProvider.minutes_divided_clec.page(params[:page]).per(@limit)
  end

  def minutes_from_outbound_carrier
    @limit = params[:limit] || PER_PAGE
    @reports = Kaminari.paginate_array(DataListenerAniCarrier.minutes_from_outbound_carrier)
                       .page(params[:page]).per(@limit)
  end

  def day_broken_by_stream
    assigned_gateways = current_user.is_rca? ? DataGateway.with_rca(current_user) : DataGateway
    @streams = assigned_gateways.joins(:data_contents)
                                .select("data_content.title as title, data_content.id as id")
                                .map{|c| [c.title, c.id]}.uniq
    @gateways = assigned_gateways.all.map{|g| [g.title, g.id]}
    @reports = current_user.day_broken_by_stream({gateway_id: params[:gateway_id] || "",
                                           week: params[:week] || DateTime.now.cweek,
                                           sort: params[:sort],
                                           direction: params[:direction],
                                           content_id: params[:stream]})
                           .page(params[:page]).per(params[:per_page] || PER_PAGE)
  end

  private
    def sort_column
      params[:sort] || "date"
    end
    
    def sort_direction
      params[:direction] || "desc"
    end
end