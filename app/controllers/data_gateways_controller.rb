class DataGatewaysController < ApplicationController
  respond_to :js, :html
  before_filter :authenticate_user!
  include ApplicationHelper

  def index
  end

  def update_prompt
    begin
      flash[:hash] = "prompts"
      @station = DataGateway.find(params[:id])
      prev_welcome_prompt_id = @station.ivr_welcome_prompt_id
      prev_ask_extension_prompt_id = @station.ivr_extension_ask_prompt_id
      unless params[:data_gateway][:ivr_extension_ask_prompt_id].present?
        if @station.ivr_extension_ask_prompt_id.present?
          parameters = {:station_name => @station.title, :prompt_title => DataGatewayPrompt.find(@station.ivr_extension_ask_prompt_id).title}
          @station.create_activity :key => 'data_gateway.unassigned_ask_extension_prompt',
          :owner => current_user, :trackable_title => user_title,
          :user_title => user_title, :parameters => parameters
        end
      end
      unless params[:data_gateway][:ivr_welcome_prompt_id].present?
        if @station.ivr_welcome_prompt_id.present?
          parameters = {:station_name => @station.title, :prompt_title => DataGatewayPrompt.find(@station.ivr_welcome_prompt_id).title}
          @station.create_activity :key => 'data_gateway.unassigned_welcome_prompt',
          :owner => current_user, :trackable_title => user_title,
          :user_title => user_title, :parameters => parameters
        end
      end
      if @station.update_attributes(params[:data_gateway])
        welcome_prompt_id = params[:data_gateway][:ivr_welcome_prompt_id]
        if welcome_prompt_id.present?
          prompt = DataGatewayPrompt.find(params[:data_gateway][:ivr_welcome_prompt_id])
          parameters = {:station_name => @station.title, :prompt_title => prompt.title}
          @station.create_activity :key => 'data_gateway.update_welcome_prompt',
          :owner => current_user, :trackable_title => user_title,
          :user_title => user_title, :parameters => parameters if prev_welcome_prompt_id.to_s != welcome_prompt_id
        end
        ask_extension_prompt_id = params[:data_gateway][:ivr_extension_ask_prompt_id]
        if ask_extension_prompt_id.present?
          prompt = DataGatewayPrompt.find(params[:data_gateway][:ivr_extension_ask_prompt_id])
          parameters = {:station_name => @station.title, :prompt_title => prompt.title}
          @station.create_activity :key => 'data_gateway.update_ask_extension_prompt',
          :owner => current_user, :trackable_title => user_title,
          :user_title => user_title, :parameters => parameters if prev_ask_extension_prompt_id.to_s != ask_extension_prompt_id
        end
        redirect_to :back, notice: "You have successfully updated prompts."
      else
        redirect_to :back, alert: @station.errors.full_messages
      end

    rescue Exception => e
     redirect_to :back, alert: "Cannot save changes, Please update or replace your logo. and  try updating your prompt again."
   end
 end

  def update_station
    flash[:hash] = "information"
    @station = DataGateway.find(params[:id])
    gateway_old_state = @station.dup
    @station.assign_attributes(params[:data_gateway])
    changed = @station.changed
    changed_params = []
    if @station.save
      if changed.present?
        changed.each do |value|
          old_state = nil
          new_state = nil
          field = nil
          case value
            when 'rca_id'
              old_state = gateway_old_state.data_group_rca.title rescue nil
              new_state = @station.data_group_rca.title rescue nil
              field = "RCA"
            when 'rca_monitor_id'
              old_state = gateway_old_state.data_group_rca_monitor.title rescue nil
              new_state = @station.data_group_rca_monitor.title rescue nil
              field = "RCA Monitor"
            when 'broadcast_id'
              old_state = gateway_old_state.data_group_broadcast.title rescue nil
              new_state = @station.data_group_broadcast.title rescue nil
              field = "Broadcaster"
            when 'country_id'
              old_state = gateway_old_state.data_group_country.title rescue nil
              new_state = @station.data_group_country.title rescue nil
              field = "Country"
            when 'language_id'
              old_state = gateway_old_state.data_group_language.title rescue nil
              new_state = @station.data_group_language.title rescue nil
              field = "Language"
            when 'data_entryway_id'
              old_state = DataEntryway.find(gateway_old_state.data_entryway_id).title rescue nil
              new_state = DataEntryway.find(@station.data_entryway_id).title rescue nil
              field = "Main DID"
            else
              old_state = gateway_old_state.send(value)
              new_state = @station.send(value)
              field = value.gsub('_', ' ')
          end
          changed_params << {field: field,
                             old_state: old_state,
                             new_state: new_state}
        end
      end
    end
    if changed_params.present?
      @station.create_activity key: 'data_gateway.update_information',
                                user_title: current_user.title,
                                owner: current_user,
                                trackable_title: @station.title,
                                parameters: {changed: changed_params,
                                             gateway_id: @station.id}
    end
  end

  def manage_phones
    if params[:selected_dids].present?
      gateway = nil
      entryway = nil
      params[:selected_dids].each do |did|
        entryway = DataEntryway.find_by_id(did.to_i)
        gateway = entryway.gateway
        entryway.update_attributes(gateway_id: nil) if entryway.present?
      end
      gateway.create_activity key: 'data_gateway.remove_phone',
                              owner: current_user,
                              trackable_title: gateway.title,
                              user_title: user_title,
                              parameters: {did: entryway.did_e164, gateway_id: gateway.id}
      redirect_to :back, notice: "Successfully deleted phone numbers."
    else
      redirect_to :back, notice: "There's no phone to be deleted."
    end
  end

  def add_phone
    if params[:data_gateway][:custom_entryways].to_i != 0
      @station = DataGateway.find_by_id(params[:id])
      @phone = DataEntryway.find_by_id(params[:data_gateway][:custom_entryways].to_i)
      DIDWATCH_LOG.debug "Assigning did #{@phone.id}: #{@phone.did_e164} to station #{@station.id}: #{@station.title}"
      unless @phone.gateway_id.present?
        if @phone.update_attributes(gateway_id: @station.id)
          @station.create_activity key: 'data_gateway.add_phone', owner: current_user, user_title: user_title, trackable_title: @station.title, parameters: {gateway_id: @station.id, entryway_id: @phone.id}, sec_trackable_title: @phone.did_e164
          DIDWATCH_LOG.info "Controller says: success! #{@phone.to_json}"
        redirect_to :back, notice: "You have successfully added new phone number."
        else
          DIDWATCH_LOG.error "Controller says: fail! Error Occured. Please try again. #{@phone.to_json}"
          redirect_to :back, alert: "Error Occured. Please try again."
        end
      else
        DIDWATCH_LOG.error "Controller says: fail! Phone number is already been taken #{@phone.to_json}"
        redirect_to :back, alert: "Phone number is already been taken."
      end
    else
      DIDWATCH_LOG.warning "Controller says: warning! No phone number was inputted. Please try again #{@phone.to_json}"
      redirect_to :back, alert: "No phone number was inputted. Please try again."
    end
  end

  def create_extension
    @station = DataGateway.find_by_id(params[:id])
    extension_params = params[:data_content]
    return redirect_to :back, alert: "Media URL can't be blank." unless extension_params[:media_url].present?
    extension_params[:media_url] = extension_params[:media_url].gsub("[", "").gsub("]", "").gsub("\"", "")
    extension = extension_params.delete(:extension)
    return redirect_to :back, alert: "Channel Number can't be blank" unless extension.present?
    return redirect_to :back, alert: "Invalid Channel Number" if extension.to_i == 0
    if DataContent.where(id: extension_params[:media_url]).first.present?
      content = DataContent.where(id: extension_params[:media_url]).first
      @station.data_gateway_conferences.create(content_id: content.id, extension: extension)
      redirect_to :back, notice: "You have successfully linked stream to this station."
    else
      return redirect_to :back, alert: "Stream not found." if rca?
      content = DataContent.create(extension_params)
      @station.data_gateway_conferences.create(content_id: content.id, extension: extension)
      redirect_to :back, notice: "You have created new extension."
    end
  end

  #==========================================================================
  # Method: get
  # Parameters:
  # + name:, format:
  # Responses:
  #  - prompts.js.haml
  # Description: Loading prompts tab for Settings page
  # Notes:
  #==========================================================================
  def prompts
    @prompt = DataGatewayPrompt.new
    @station = DataGateway.find params[:data_gateway_id]
    @prompts = @station.data_gateway_prompts

    respond_to do |format|
      format.js
    end
  end

  def new
    @station = DataGateway.new
  end

  def create
    if marketer?
      @new_station = DataGateway.new(params[:data_gateway])
      if @new_station.save
        entryway = DataEntryway.where(:id => params[:data_gateway][:data_entryway_id]).first rescue nil
        if entryway.present?
          flash[:alert] = "The DID you were trying to assign is already been taken" if entryway.gateway_id.present?
          unless entryway.gateway_id.present?
            entryway.update_attribute('gateway_id', @new_station.id)
            @new_station.create_activity key: 'data_gateway.create',
                                         owner: current_user,
                                         user_title: user_title,
                                         trackable_title: @new_station.title,
                                         parameters: {gateway_id: @new_station.id, entryway_id: entryway.id},
                                         sec_trackable_title: entryway.did_e164
          end
        end
        flash[:notice] = "You have successfully created new station."
        @next = settings_station_path(@new_station.id)
      end
    else
      flash[:alert] = "You don't have the rights to perform necessary action."
      @next = root_url
    end
  end

  def create_dup
    if marketer?
      if params[:id].present?
        station = DataGateway.find(params[:id])
        dupstation = station.deep_clone :except => [:broadcast_id, :rca_id, :logo, :logo_file_name], :use_dictionary => true
        dupstation.title = "DUP #{station.title}"
        if dupstation.save
          if station.data_gateway_conferences.count > 0
            station.data_gateway_conferences.each do |conference|
              dupstation.data_gateway_conferences.new(:content_id => conference.content_id, :extension => conference.extension).save(:validate => false)
            end
          end
          station.prompts.each do |s|
            prompts = s.deep_clone :use_dictionary => true
            if prompts.save
              prompts.update_attribute('gateway_id', dupstation.id)
              blob = s.data_gateway_prompt_blob
              if blob.present?
               DataGatewayPromptBlob.create(:id => prompts.id, :binary =>blob.binary)
              end
            end
          end
          brd = DataGroupBroadcast.where(:id => station.broadcast_id) if station.broadcast_id.present?
          rca = DataGroupRca.where(:id => station.rca_id) if station.rca_id.present?
          dupstation.update_attributes({:data_group_broadcast => brd.first}) if brd.present?
          dupstation.update_attributes({:data_group_rca => rca.first}) if rca.present?
          flash[:notice] = "You have successfully duplicate #{station.title} station."
          redirect_to settings_station_path(dupstation.id)
          # render :json => dupstation
        end
      end
    end
  end

    # if current_user.is_marketer?
    #   @station = DataGateway.new(params[:data_gateway])
    #   if @station.save
    #     free_entryway_ids = params[:'free_entryway_ids']
    #     thirdparty_ids = params[:'3rdparty_ids']

    #     entryway_ids_hash = {}
    #     free_entryway_ids.each_with_index do |entry_id, index|
    #       if !entryway_ids_hash[entry_id.to_i]
    #         entryway_ids_hash[entry_id.to_i] = thirdparty_ids[index].to_i
    #       end
    #     end

    #     entryways = DataEntryway.where(:id => entryway_ids_hash.keys)


    #     entryways.each do |entry|
    #       if entryway_ids_hash[entry.id] != 0
    #         entry.send("3rdparty_id=", entryway_ids_hash[entry.id])
    #       end
    #       entry.gateway_id = @station.id
    #       entry.save
    #     end


    #     redirect_to settings_path, notice: "Created successfully."
    #   else
    #     flash[:error] = "Please input the requied fields in (*)"
    #     flash[:error] =  "<ul>" + @station.errors.messages.values.map { |o| o.map{|p| "<li>"+p+"</li>"}.join(" ") }.join(" ") + "</ul>"
    #     render :action => 'new'
    #   end
    # end
  # end


  def edit
    @station = DataGateway.find(params[:id])
    @entryways = @station.data_entryways
  end

  # def update
  #   gateway = DataGateway.find_by_id(params[:id])
  #    content_id =  params[:data_gateway].present? && params[:data_gateway]["data_gateway_conferences_attributes"].present? ? params[:data_gateway]["data_gateway_conferences_attributes"]["0"]["content_id"] : nil
  #    if content_id.present?
  #      data_content = DataContent.find(content_id)
  #      data_content.update_attribute(:is_deleted,false) if data_content.is_deleted == true
  #    end
  #   status = gateway.update_attributes(params[:data_gateway])
  #
  #   if status
  #     redirect_to :back, notice: "Your gateway was successfully updated."
  #   else
  #
  #     flash[:error] =  "<ul>" + gateway.errors.messages.values.map { |o| o.map{|p| "<li>"+p+"</li>"}.join(" ") }.join(" ") + "</ul>"
  #     flash[:error] = flash[:error] + "<ul><li>Your gateway was unsuccessfully updated.</li></ul>"
  #     redirect_to :back
  #   end
  #
  # end

  def update
    gateway = DataGateway.find_by_id(params[:id])
    content_id =  params[:data_gateway].present? && params[:data_gateway]["data_gateway_conferences_attributes"].present? ? params[:data_gateway]["data_gateway_conferences_attributes"]["0"]["content_id"] : nil
    if content_id.present?
      data_content = DataContent.find(content_id)
      data_content.update_attribute(:is_deleted,false) if data_content.is_deleted == true
    end
    status = gateway.update_attributes(params[:data_gateway])

    if status
      redirect_to :back, notice: "Your gateway was successfully updated."
    else

      flash[:error] =  "<ul>" + gateway.errors.messages.values.map { |o| o.map{|p| "<li>"+p+"</li>"}.join(" ") }.join(" ") + "</ul>"
      flash[:error] = flash[:error] + "<ul><li>Your gateway was unsuccessfully updated.</li></ul>"
      redirect_to :back
    end

  end

  def destroy
    @gateway = DataGateway.find_by_id(params[:id])
    if @gateway.is_deleted
      redirect_to new_settings_path, notice: "Your gateway has been deleted."
    elsif @gateway.update_attributes(is_deleted: true)

      @gateway.create_activity key: 'data_gateway.destroy_gateway', owner: current_user, trackable_title: @gateway.title, parameters: {:gateway_id => @gateway.id}
      redirect_to new_settings_path, notice: "Your gateway was successfully deleted."
    else
      flash[:error] =  "<ul>" + @gateway.errors.messages.values.map { |o| o.map{|p| "<li>"+p+"</li>"}.join(" ") }.join(" ") + "</ul>"
      flash[:error] = flash[:error] + "<ul><li>Your gateway was unsuccessfully deleted.</li></ul>"
      redirect_to new_settings_path
    end
  end

  def request_content
    email_config = SysConfig.get_config("UI_CONFIG",
      "EMAIL")
    if !email_config
      emails = User.joins(:sys_user_permission).where("sys_user_permission.is_super_user" => true).pluck(:email)
    else
      emails = [email_config.value]
    end
    UserMailer.request_content(params[:suggestion].merge!({to_emails: emails, from_email: current_user.email})).deliver
    redirect_to :back, notice: "Thanks for your request."
  end
  
  def check_channel_number
    id = params[:id]
    channel = params[:channel]
    @extension = DataGatewayConference.where(["gateway_id = ? AND extension = ?", id, channel])
    render :json => @extension.count
  end

  def delete_logo
    if params[:station_id].present?
      stn = DataGateway.find(params[:station_id])
      stn.logo = nil
      if stn.save!
        flash[:notice] = "Logo has been successfully purged!"
      end
    end
    redirect_to "/new_settings/station/#{stn.id}"
  end

  def request_widget_did
    if request.xhr?
      station = DataGateway.find(params[:id]) rescue nil
      if station.present?
        render json: {error: 0, message: 'Success, We will respond to your request as soon as possible.'} if RequestWidgetMailer.request_widget_did(station, current_user).deliver
      else
        render json: {error: 1, message: 'Gateway not found!'}
      end
    end
  end

  def update_gateway_prop
    params[:player_autoplay] ||= 0
    params[:player_zeno_logo] ||= 1
    if request.xhr?
      station = DataGateway.find(params[:gateway_id]) rescue nil
      if station.present?
        extensions = station.data_gateway_conferences.count
        if extensions > 1
          station.metadata = params[:metadata]
        else
          station.data_gateway_conferences.first.data_content.onair_title = params[:metadata]
        end
        station.player_autoplay = params[:player_autoplay]
        station.player_zeno_logo = params[:player_zeno_logo]
        extensions = station.data_gateway_conferences
        ext_count = extensions.count
        station.metadata = params[:metadata] if ext_count > 1
        if ext_count == 1
          extensions.first.data_content.update_attributes({onair_title: params[:metadata]})
          station.metadata = nil
        end
        station.widget_is_set_up = true
      end
      begin
        data = station.save!
        station.create_activity key: 'data_gateway.request_snippet',
                                owner: current_user, trackable_title: station.title,
                                user_title: user_title,
                                parameters: {gateway_id: station.id}
        Delayed::Job.enqueue MassRadioJarUpdate.new(station.id), 0
        render json: {error: 0, message: 'Success', data: data}
      rescue => e
        render json: {error: 1, message: e.message}
      end
    end
  end

end
