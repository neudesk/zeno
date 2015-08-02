class NewSettingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_station, except: [:index, :list_phone_numbers, :station,
                                       :detach_phone, :data_group, :save_data_groups,
                                       :data_group_delete, :send_widget_request,
                                       :data_tagging, :save_data_tagging, :delete_data_tagging, :check_access]
  before_filter :restrict_admin_only, only: [:data_tagging, :data_group, :data_group_delete, :save_data_tagging, :save_data_groups]

  def index
    @new_station = DataGateway.new
    @stationsNum = 0
    if current_user.stations.present?
      @stationsNum = current_user.stations.count.to_i
      is_one_monitor_gateway = false
      if current_user.is_rca?
        rca_ids = current_user.data_group_rcas.present? ? current_user.data_group_rcas.collect(&:id) : []
        if rca_ids.include? current_user.stations.first.rca_monitor_id and current_user.stations.count == 1
          is_one_monitor_gateway = true
        end
      end
      redirect_to settings_station_path(current_user.stations.first.id) if current_user.stations.count == 1
    end
  end

  def station
    params[:page] ||= 1
    @station_tool = StationTool.new
    @new_station = DataGateway.new
    if params[:station_id].present?
      @new_extension = DataContent.new
      @station = DataGateway.find_by_id(params[:station_id])
      if @station.present?
        @extensions =  @station.data_gateway_conferences
        @phone_numbers = @station.data_entryways
        @prompts = @station.prompts
        @prompt = DataGatewayPrompt.new
        @notes = Kaminari.paginate_array(@station.data_gateway_notes.order('created_at DESC')).page(params[:page]).per(10) if @station.data_gateway_notes.present?
        where = []
        where.push("trackable_id IN (#{@station.id.to_s}) AND trackable_type IN ('DataGateway')") if @station.id.present?
        where.push("trackable_id IN (#{@station.data_contents.collect(&:id).join(',')}) AND trackable_type IN ('DataContent')") if @station.data_contents.present?
        where.push("trackable_id IN (#{@station.data_gateway_prompts.collect(&:id).join(',')}) AND trackable_type IN ('DataGatewayPrompt')") if @station.data_gateway_prompts.present?
        where.push("sec_trackable_title=#{@station.id} AND sec_trackable_type IN ('DataGateway')") if @station.id.present?
        @activities = PublicActivity::Activity.where("#{where.join(' OR ')}").limit(15).order("created_at DESC")
        @entryways = @station.data_entryways
        @widget_did = @entryways.where("substr(did_e164,1,4) in ('1700')").first rescue nil
        @brd_has_no_content = DataContent.select([:id]).where(broadcast_id: @station.broadcast_id).empty?
        @metadata = (@station.data_gateway_conferences.count == 1) ? @station.data_gateway_conferences.first.data_content.onair_title : @station.metadata
      end
    end
    @user = User.joins(data_group_broadcasts:[:data_gateways]).where("data_gateway.id = #{params[:station_id]}").first
    search_params = {}
    search_params['query'] = params[:query] if params[:query].present?
    search_params['country_id'] = params[:country_id] if params[:country_id].present?
    search_params['rca_id'] = params[:rca_id] if params[:rca_id].present?
    @return_params = search_params.to_query if search_params.present?
  end

  def detach_phone
    if params[:phone_id].present?
      entryway = DataEntryway.find_by_id(params[:phone_id].to_i)
      if entryway.update_attributes(gateway_id: nil)
        render :json => {:result => "You have successfully detached phone number #{entryway.did_e164} to this station."}
      else
        render :json => {:result => "Error detaching phone number #{entryway.did_e164} to this station."}
      end
    end
  end

  def show
    @streams =  @station.data_contents
    @phone_numbers = @station.data_entryways
  end

  def list_phone_numbers
    phonedata = DataEntryway.where(gateway_id: nil, is_deleted: false).order(:title).collect{ |x| [x.title, x.id]}
    render :json => phonedata
  end

  def set_station
    @station = current_user.stations.find_by_id(params[:id])
    redirect_to root_url, alert: "Not Authorized." unless @station.present?
  end

  def check_access
    if params[:access_key].present? and params[:access_key] == 'ZenoAdmin04!'
      session[:authorized_access] = current_user.id
      redirect_to data_group_path
    else
      flash[:error] = 'Unauthorized access'
    end
  end

  def data_group
    redirect_to data_group_authorized_path unless session[:authorized_access].present?
    @countries = DataGroupCountry.select([:id, :title]).order('title')
    @user_group = 'RCA'
    @data_user = DataGroupRca.select([:id, :title]).order('title')
    @rcas = DataGroupRca.select([:id, :title]).order('title')
    @rca_sel = params[:rca_filter]
    @station_filter = nil
    params[:per] ||= 20
    if params[:user_group].present?
      case params[:user_group]
        when "RCA"
          @data_user = DataGroupRca.select([:id, :title]).order('title')
          objects = DataGateway.select([:id, :title, :country_id]).order('title')
          objects = objects.where(rca_id: @rca_sel) if params[:rca_filter].present?
        when "BroadCaster"
          @data_user = DataGroupBroadcast.select([:id, :title]).order('title')
          objects = DataGateway.select([:id, :title, :country_id]).order('title')
          objects = objects.where(rca_id: @rca_sel) if params[:rca_filter].present?
        when "ThirdParty"
          @data_user = DataGroup3rdparty.select([:id, :title]).order('title')
          objects = DataEntryway.select([:id, :title, :country_id, :did_e164]).order('title')
          @providers = []
          objects.each do |obj|
            prov = obj.title.split('-').first.strip
            @providers << prov if !@providers.include? prov
          end
      end
      if params[:data_user_selected].present?
        @data_user_selected = @data_user.where(:id => params[:data_user_selected]).first
        @objects = objects
        if params[:user_group] == 'ThirdParty'
          @selected = @data_user_selected.entryways.collect(&:id)
        else
          @selected = @data_user_selected.gateways.collect(&:id)
        end
      end
      if params[:country].present?
        @country = @countries.where(:id => params[:country]).first
        @objects = @objects.where(:country_id => @country.id) if @objects.present?
      end
      if params[:station_filter].present? && @objects.present?
        @objects = @objects.where(['TRIM(LOWER(title)) LIKE ?', "%#{params[:station_filter].downcase.strip}%"])
        @station_filter = params[:station_filter]
      end
      if params[:per].present?
        @per_selected = params[:per]
      end
      if params[:provider].present?
        @provider_selected = params[:provider]
        @objects = @objects.where(['TRIM(LOWER(title)) LIKE ?', "%#{params[:provider].downcase.strip}%"])
      end
      if params[:did_filter].present?
        @did_filter = params[:did_filter]
        @objects = @objects.where(['TRIM(LOWER(did_e164)) LIKE ?', "%#{params[:did_filter].downcase.strip}%"])
      end
      @user_group = params[:user_group]
    end
    @objects = Kaminari.paginate_array(@objects).page(params[:page]).per(params[:per]) if @objects.present?
    if request.xhr?
      render :layout => false
    end
  end

  def data_group_delete
    parameters = {:group_type => nil}
    key = 'data_gateway.delete_grouping'
    case params[:user_group]
      when "RCA"
        object = DataGateway.find(params[:id])
        old_id = object.rca_id
        object.update_attributes(:rca_id => nil)
      when "BroadCaster"
        object = DataGateway.find(params[:id])
        old_id = object.broadcast_id
        object.update_attributes(:broadcast_id => nil)
      when "ThirdParty"
        object = DataEntryway.find_by_id(params[:id])
        old_id = object.send("3rdparty_id")
        object.update_attributes("3rdparty_id" => nil)
        key = 'data_entryway.delete_grouping'
    end
    parameters[:group_type] = params[:user_group]
    parameters[:object_title] = object.title
    parameters[:old_id] = old_id
    object.create_activity :key => key, :owner => current_user, :trackable_title => user_title, :user_title => user_title, :parameters => parameters
    render :json => {:object => object, :user_group => params[:user_group]}
  end

  def save_data_groups
    parameters = {:group_type => nil}
    key = 'data_gateway.grouping'
    case params[:user_group]
      when "ThirdParty"
        group = DataGroup3rdparty.find_by_id(params[:data_user_selected])
        object = DataEntryway.find(params[:data_object_id])
        old_id = object.send("3rdparty_id")
        object.update_attributes("3rdparty_id" => group.id)
        new_id = object.send("3rdparty_id")
        key = 'data_entryway.grouping'
      when "BroadCaster"
        group = DataGroupBroadcast.find_by_id(params[:data_user_selected])
        object = DataGateway.find(params[:data_object_id])
        old_id = object.broadcast_id
        object.update_attributes(:broadcast_id => group.id)
        new_id = object.broadcast_id
      when "RCA"
        group = DataGroupRca.find_by_id(params[:data_user_selected])
        object = DataGateway.find(params[:data_object_id])
        old_id = object.rca_id
        object.update_attributes(:rca_id => group.id)
        new_id = object.rca_id
    end
    parameters[:group_type] = params[:user_group]
    parameters[:object_title] = object.title
    parameters[:old_id] = old_id
    parameters[:new_id] = new_id
    object.create_activity :key => key, :owner => current_user, :trackable_title => user_title, :user_title => user_title, :parameters => parameters
    render :json => {:group => group, :object => object}
  end

  def data_tagging
    redirect_to data_group_authorized_path unless session[:authorized_access].present?
    if params[:tag_type].present?
      @sel_tag_type = params[:tag_type]
      @sel_tag = params[:tag]
      params[:page] ||= 1
      case params[:tag_type]
        when 'Country'
          @tags = DataGroupCountry.select([:id, :title]).order('title')
          sel_tag = @tags.find(params[:tag]) if params[:tag].present?
          @selected = sel_tag.gateways.collect(&:id) if sel_tag.present?
          @objects = DataGateway.select([:id, :title]).order('title') if params[:tag].present?
          @objects = @objects.where(country_id: params[:tag_filter]) if params[:tag_filter].present?
        when 'Genre'
          @tags = DataGroupGenre.select([:id, :title]).order('title')
          sel_tag = @tags.find(params[:tag]) if params[:tag].present?
          @selected = sel_tag.contents.collect(&:id) if sel_tag.present?
          @objects = DataContent.select([:id, :title]).order('title') if params[:tag].present?
          @objects = @objects.where(genre_id: params[:tag_filter]) if params[:tag_filter].present?
        when 'Language'
          @tags = DataGroupLanguage.select([:id, :title]).order('title')
          sel_tag = @tags.find(params[:tag]) if params[:tag].present?
          @objects = DataGateway.select([:id, :title]).order('title') if params[:tag].present?
          @selected = @objects.where(:language_id => sel_tag.id).collect(&:id) if sel_tag.present?
          @objects = @objects.where(language_id: params[:tag_filter]) if params[:tag_filter].present?
      end

      if params[:tag].present?
        @objects = @objects.where(['Tgenre_idRIM(LOWER(title)) LIKE ?', "%#{params[:station_filter].downcase.strip}%"]) if params[:station_filter].present?
      end
      @objects = Kaminari.paginate_array(@objects).page(params[:page]).per(params[:per]) if @objects.present?
      @per = params[:per] if params[:per]
    end

    if request.xhr?
      # render :layout => false
    end
  end

  def save_data_tagging
    parameters = {:group_type => params[:tag_type]}
    key = 'data_content.tagging'
    object_id = params[:station_id]
    case params[:tag_type]
      when 'Country'
        country = DataGroupCountry.find(params[:tag])
        object = DataGateway.find(params[:object_id])
        object.update_attributes(:country_id => country.id)
        new_id = country.id
        key = 'data_gateway.tagging'
      when 'Genre'
        genre = DataGroupGenre.find(params[:tag])
        object = DataContent.find(params[:object_id])
        object.update_attributes(:genre_id => genre.id)
        new_id = object.genre_id
      when 'Language'
        language = DataGroupLanguage.find(params[:tag])
        object = DataGateway.find(params[:object_id])
        object.update_attributes(:language_id => language.id)
        new_id = object.language_id
    end
    parameters[:object_title] = object.title
    parameters[:new_id] = new_id
    object.create_activity :key => key, :owner => current_user, :trackable_title => user_title, :user_title => user_title, :parameters => parameters
    render :json => {:status => '200'}
  end

  def delete_data_tagging
    parameters = {:group_type => params[:tag_type]}
    key = 'data_content.delete_tagging'
    object_id = params[:station_id]
    case params[:tag_type]
      when 'Country'
        country = DataGroupCountry.find(params[:tag])
        object = DataGateway.find(params[:object_id])
        old_id = object.country_id
        object.update_attributes(:country_id => nil)
        key = 'data_gateway.delete_tagging'
      when 'Genre'
        genre = DataGroupGenre.find(params[:tag])
        object = DataContent.find(params[:object_id])
        old_id = object.genre_id
        object.update_attributes(:genre_id => nil)
      when 'Language'
        language = DataGroupLanguage.find(params[:tag])
        object = DataGateway.find(params[:object_id])
        old_id = object.language_id
        object.update_attributes(:language_id => nil)
    end
    parameters[:group_type] = params[:tag_type]
    parameters[:object_title] = object.title
    parameters[:old_id] = old_id
    object.create_activity :key => key, :owner => current_user, :trackable_title => user_title, :user_title => user_title, :parameters => parameters
    render :json => {:status => '200'}
  end

  def send_widget_request
    gateway = DataGateway.find(params[:station_id]) if params[:station_id].present?
    station_tool = StationTool.create!(params[:station_tool])
    if station_tool.tool_type == 'mobile_app'
      subject = "Subject: #{gateway.title} Station Mobile App Request"
    else
      subject = "Subject: #{gateway.title} Media Player Request"
    end
    if gateway.present?
      rca = User.joins(:data_group_rcas => [:data_gateways]).where("data_gateway.id = #{gateway.id}").first
      recipients = ['rt@zenoradio.com', 'jon@zenoradio.com']
      recipients << rca.email if rca.present?
      content = {:rca => gateway.data_group_rca.present? ? gateway.data_group_rca.title : 'rt@zenoradio.com',
                 :to => recipients,
                 :from => current_user,
                 :subject => subject,
                 :player_data => station_tool}
      if RequestWidgetMailer.send_request_media_player_widget(content)
        flash[:notice] = "Request has been sent."
        parameters = {:tool_type => station_tool.tool_type,
                      :station_title => gateway.title}
        station_tool.create_activity :key => 'station_tool.request_tool',
                                     :owner => current_user,
                                     :trackable_title => user_title,
                                     :user_title => user_title,
                                     :parameters => parameters
        flash[:notice] = "We have successfuly received your request."
      end
    end
    redirect_to "/new_settings/station/#{gateway.id}"
  end

end
