class ExtensionsController < ApplicationController
  before_filter :authenticate_user!
  
  DIDS_PAGE_SIZE = 48 


  #==========================================================================
  # Method: get
  # Parameters:
  # + name:, format:
  # Responses:
  #  - index.js.haml
  # Description: Loading extensions tab for Settings page
  # Notes: 
  #==========================================================================
  def index
    @station_id = params[:station_id] || @stations.try(:first).try(:id)
    if @station_id
      @station = DataGateway.find @station_id
      @entryways = @station.data_entryways.page(params[:page]).per(DIDS_PAGE_SIZE)
    end
    
    #    get_extensions_data
    get_current_extensions

    respond_to do |format|
      format.js
    end
  end

  #==========================================================================
  # Method: get
  # Parameters:
  # + name:, format:
  # Responses:
  #  - content.html.haml
  # Description: Loading content section
  # Notes: 
  #==========================================================================
  def content
    if params[:station_id] || (@stations && @stations.length > 0)
      @station_id = params[:station_id] || @stations.first.id
      @station = DataGateway.find(@station_id)
      #      get_extensions_data
      get_current_extensions
    end

    render :partial => "content", locals: {station_id: @station_id,
      extensions: @extensions,
      countries: @countries,
      other_contents: @other_contents
    }
  end

  #==========================================================================
  # Method: get
  # Parameters:
  #  - station_id: selected station id 
  #  - search_stream: stream name (content title) for searching contents
  # Responses:
  #  - add_existing_gateway_content.js.haml
  # Description: 
  #  - loading "adding existing contents (unused contents) to selected station" dialog
  # Notes: 
  #==========================================================================
  def add_existing_gateway_content
    @station_id = params[:station_id]
    if @station_id
      @station = DataGateway.find @station_id
      @entryways = @station.data_entryways.page(params[:page]).per(DIDS_PAGE_SIZE)
    end
    
    extensions = @station.data_contents

    #    @countries = DataGroupCountry.where("id NOT IN (?) OR id=0", (!extensions.blank? && extensions.map(&:country_id).compact) || "").order(:title).uniq.map{|c| [c.title, c.id]}   
    @countries = DataGroupCountry.order(:title).uniq.map{|c| [c.title, c.id]}
    @dataGatewayConference = DataGatewayConference.new
    @search_stream = params[:search_stream]

    if @search_stream
      searched_contents = DataContent.search_by_stream_name(@search_stream)
      searched_content = searched_contents.first if searched_contents.count > 0
      if searched_content
        @default_country_id = searched_content.country_id
        country = searched_content.data_group_country
        # default content id which is selected in the select box in default
        @default_content_id = searched_content.id
      end
    end

    country_id = country.present? ? country.id : 0

    # select unused contents in the selected station
    @other_contents = DataContent.where("id NOT IN (?)", (!extensions.blank? && extensions.map(&:id)) || "").where('is_deleted = false and country_id = ?', country_id).order("trim(title)").map{|c| [c.title, c.id]}

    respond_to do |format|
      format.js
      format.json { render :json => searched_contents.map { |c| {:id => c.id, :value => c.title} } }    
    end

  end

  #==========================================================================
  # Method: post
  # Parameters:
  # + name:, format:
  # Responses:
  #  - save_existing_gateway_content.js.haml
  # Description: Adding existing content to selected station (submit)
  # Notes: 
  #==========================================================================
  def save_existing_gateway_content

    @dataGatewayConference = DataGatewayConference.new(params[:data_gateway_conference])
    
    if @dataGatewayConference.save
      flash[:notice] = "Added successfully."
    else
      flash[:error] =  "<ul>" + @dataGatewayConference.errors.messages.values.map { |o| o.map{|p| "<li>"+p+"</li>"}.join(" ") }.join(" ") + "</ul>"
    end

    respond_to do |format|
      format.js
    end


  end

  #==========================================================================
  # Method: get
  # Parameters:
  # + name:, format:
  # Responses:
  #  - edit_gateway_content.js.haml
  # Description: Loading edit content dialog for selected station
  # Notes: 
  #==========================================================================
  def edit_gateway_content
    @dataGatewayConference = DataGatewayConference.find params[:gateway_content_id]

    respond_to do |format|
      format.js
    end

  end


  #==========================================================================
  # Method: put
  # Parameters:
  # + name:, format:
  # Responses:
  #  - edit_gateway_content.js.haml
  # Description: Loading edit content dialog for selected station
  # Notes: 
  #==========================================================================
  def update_gateway_content
    if !current_user.is_thirdparty?

      @dataGatewayConference = DataGatewayConference.find(params[:gateway_content_id])
      
      old_url = @dataGatewayConference.data_content.media_url
      old_backup = @dataGatewayConference.data_content.backup_media_url
      old_name = DataGatewayConference.find(params[:gateway_content_id]).data_content.title
      old_extension = DataGatewayConference.find(params[:gateway_content_id]).extension
      
      old_media_type = @dataGatewayConference.data_content.media_type
      new_media_type = params[:data_gateway_conference][:data_content_attributes][:media_type]

      success_update = @dataGatewayConference.update_attributes(params[:data_gateway_conference])
      
      new_name = DataGatewayConference.find(params[:gateway_content_id]).data_content.title
      new_extension = DataGatewayConference.find(params[:gateway_content_id]).extension
      data_content = @dataGatewayConference.data_content    

      new_url = @dataGatewayConference.data_content.media_url
      new_backup = @dataGatewayConference.data_content.backup_media_url

      if success_update
        if old_media_type != new_media_type
           data_content.create_activity key: 'data_content.media_type', owner: current_user, trackable_title: data_content.title, user_title: user_title,
            parameters: {:old_media_type =>old_media_type, :new_media_type => new_media_type, :channel_no => old_extension}
        end
        
        if old_url == new_backup && old_backup == new_url
          data_content.create_activity key: 'data_content.switch_stream', owner: current_user, trackable_title: data_content.title, user_title: user_title,
            parameters: {:old_url =>old_url, :new_url => new_url, :channel_no => @dataGatewayConference.extension, :station => data_content.data_gateways.first.title }     
        elsif old_url != new_url
          data_content.create_activity key: 'data_content.change_stream_url', owner: current_user, trackable_title: data_content.title, user_title: user_title,
            parameters: {:old_url =>old_url, :new_url => new_url, :channel_no => @dataGatewayConference.extension}
        elsif  new_backup != old_backup 
          data_content.create_activity key: 'data_content.backup_media_url', owner: current_user, user_title: user_title,
          trackable_title: data_content.title, parameters: {:old_backup =>old_backup, :new_backup=> new_backup, :channel_no => old_extension} 
        end
        
        if old_name != new_name
          data_content.create_activity key: 'data_content.change_name', owner: current_user, trackable_title: data_content.title, user_title: user_title,
            parameters: {:old_name => old_name, :new_name => new_name, :channel_no => @dataGatewayConference.extension}
        end
        flash[:notice] = "Updated successfully."
        if old_extension != new_extension
          station = DataGateway.find(@dataGatewayConference.gateway_id)
          station.create_activity key: 'data_gateway.move_content', owner: current_user, 
            parameters: {:old_extension => old_extension, :new_extension => new_extension, :content_id => @dataGatewayConference.content_id },
            trackable_title: station.title, user_title: user_title, 
            sec_trackable_title: @dataGatewayConference.data_content.title, sec_trackable_type: 'DataContent'
        end
      else
        @dataGatewayConference.errors.messages.values.map { |o| o.map{|p| "<li>"+p+"</li>"}.join(" ") }.join(" ")
        flash[:error] =  "<ul>" + @dataGatewayConference.errors.messages.values.map { |o| o.map{|p| "<li>"+p+"</li>"}.join(" ") }.join(" ") + "</ul>"
      end

      respond_to do |format|
        format.js
      end

    end
    
  end

  #==========================================================================
  # Method: get
  # Parameters:
  # + name:, format:
  # Responses:
  #  - search_stream.html.haml
  # Description: Search stream inside Add New Content dialog
  # Notes: 
  #==========================================================================
  def search_stream
    if params[:getid] == '1'
      render :json => DataContent.where("media_url like ?", "#{params[:query]}")
      .map { |c| {:id => c.id, :value => c.media_url} }
    else
      render :json => DataContent.where("media_url like ?", "%#{params[:query]}%")
      .map(&:media_url)
    end         
  end

  #==========================================================================
  # Method: get
  # Parameters:
  # + name:, format:
  # Responses:
  #  - get_contents.html.haml
  # Description: Get stream names(content titles) when selecting contry name in Add Extensions dialog (Contents section)
  # Notes: 
  #==========================================================================
  def get_contents

    @station_id = params[:station_id]
    content_ids = DataGatewayConference.joins(:data_content)
    .where("country_id = ? AND gateway_id =?", params[:query], @station_id)
    .uniq.map(&:content_id)

    render :json => DataContent.where("country_id = ? and id NOT IN (?)", params[:query], (!content_ids.blank? && content_ids) || "").order("trim(title)").map{|c| [c.title, c.id]}
  end

  #==========================================================================
  # Method: get
  # Parameters:
  # + name:, format:
  # Responses:
  #  - get_contents.html.haml
  # Description: Remove stream name (Contents section) in selected station
  # Notes: 
  #==========================================================================
  def destroy
    if thirdparty?
      redirect_to root_url, alert: "You have no access on the requested action."
    else
      extension = DataGatewayConference.find(params[:id])
      extension.create_activity key: 'data_gateway_conference.destroy', owner: current_user, trackable_title: extension.data_content.title, user_title: user_title,
        parameters: {:content_id => extension.data_content.id, :media_url => extension.data_content.media_url, :channel_no => extension.extension}
      if extension.destroy
        gateway = DataGateway.find(extension.gateway_id)
        extensions = gateway.data_gateway_conferences
        ext_count = extensions.count
        if ext_count == 1
          gateway.data_gateway_conferences.first.data_content.update_attributes({onair_title: gateway.metadata}) if gateway.metadata.present? and ext_count == 1
          gateway.update_attributes({metadata: nil})
        end
        redirect_to :back, notice: "You have successfully deleted a extension."
      else
        redirect_to :back, alert: "Error Occured. Please try again or contact system administrator"
      end
    end
  end

  protected

  def get_extensions_data
    @extensions = DataGatewayConference.joins(:data_content)
    .where(gateway_id:@station_id)
    .select("data_content.media_url as stream,
             data_content.media_type as stream_type,
             data_content.title as title,
             data_content.id as content_id,
             data_gateway_conference.id as extension_id,
             data_gateway_conference.extension as extension").order("data_gateway_conference.extension*1")
    @new_extensions = DataContent.where("data_content.id NOT IN (?)", (!@extensions.blank? && @extensions.map(&:content_id)) || "")
    .select("data_content.media_url as stream,
                                            data_content.media_type as stream_type,
                                            data_content.title as title,
                                            data_content.id as content_id,
                                            '' as extension_id, 
                                            '' as extension")
    @countries = DataGroupCountry.joins(:data_contents).where("data_content.id NOT IN (?)", (!@extensions.blank? && @extensions.map(&:content_id)) || "").uniq.map{|c| [c.title, c.id]}
    @other_contents = DataContent.where("id NOT IN (?) and country_id = ? ", (!@extensions.blank? && @extensions.map(&:content_id)) || "", (@countries.first && @countries.first[1]) || 0)
    .map{|c| [c.title, c.id]}
  end
  
  def get_current_extensions
    @extensions = DataGatewayConference.joins(:data_content)
    .where(gateway_id:@station_id)
    .select("data_content.media_url as stream,
             data_content.media_type as stream_type,
             data_content.title as title,
             data_content.id as content_id,
             data_gateway_conference.id as extension_id,
             data_gateway_conference.extension as extension").order("data_gateway_conference.extension*1")
    @countries = DataGroupCountry.joins(:data_contents).where("data_content.id NOT IN (?)", (!@extensions.blank? && @extensions.map(&:content_id)) || "").uniq.map{|c| [c.title, c.id]}
    @other_contents = DataContent.where("id NOT IN (?) and country_id = ? ", (!@extensions.blank? && @extensions.map(&:content_id)) || "", (@countries.first && @countries.first[1]) || 0)
    .map{|c| [c.title, c.id]} 
    @new_extensions = Array.new
  end

  

end
