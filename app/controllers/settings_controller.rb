class SettingsController < ApplicationController

  before_filter :authenticate_user!

  DIDS_PAGE_SIZE = 48

  #==========================================================================
  # Method: get
  # Parameters:
  # + name:, format:
  # Responses:
  #   - index.html.haml
  # Description: 
  #   - Loading settings page includes:
  #       + Phone Numbers section (DIDs)
  #       + 3 tabs: Extensions, Prompts, Tags
  # Notes:
  #==========================================================================
  def index
    @no_of_stations = current_user.stations.length
    @station = DataGateway.find(params[:gateway_id]) rescue @stations.try(:first)
    @station = current_user.stations.first if current_user.is_broadcaster? && @station.blank?
    if @station.present?
      @entryways = @station.data_entryways.page(params[:page]).per(DIDS_PAGE_SIZE)
      @station_id = @station.id
    end
  end


  #==========================================================================
  # Method: get
  # Parameters:
  # + name:, format:
  # Responses:
  #   - assign_did.js.haml
  # Description: 
  #   - Loading assign DIDs dialog for adding free DIDs
  # Notes:
  #==========================================================================
  def assign_dids
    @station = DataGateway.find params[:data_gateway_id]

    render "settings/dids/assign_dids"
  end


  #==========================================================================
  # Method: put
  # Parameters:
  # + name:, format:
  # Responses:
  #   - update_station_dids.js.haml
  # Description: 
  #   - Adding free DIDS to the selected station
  # Notes:
  #==========================================================================
  def update_station_dids
    if current_user.is_marketer?
      @station = DataGateway.find(params[:id])

      @entryways = @station.data_entryways.page(1).per(DIDS_PAGE_SIZE)
     
      success_update = @station.update_attributes(params[:data_gateway])      
      @selected_entry_ids = params[:selected_entry_ids].uniq
      
      if @selected_entry_ids.length > 0 && success_update
        data_entryway = ''
        @selected_entry_ids.each do |entryway_id|
          entryway = DataEntryway.find(entryway_id)
          if entryway
            data_entryway += ' ' + entryway.did_e164
          end
        end
        @station.create_activity key: 'data_gateway.create_entryway', owner: current_user, params: {:entryway => @selected_entry_ids },
          trackable_title: @station.title, user_title: user_title, 
          sec_trackable_title: data_entryway, sec_trackable_type: 'DataEntryway'
      end      

      selected_entryways = DataEntryway.where(:id => @selected_entry_ids)
      @station.data_entryways<< selected_entryways

      flash[:notice] = "Updated successfully."

      respond_to do |format|
        format.js {render "settings/dids/update_station_dids"}
      end
    end
  end

  #==========================================================================
  # Method: put
  # Parameters:
  # + name:, format:
  # Responses:
  #   - update_station_dids.js.haml
  # Description: 
  #   - Removing selected DIDS to the selected station
  # Notes:
  #==========================================================================
  def unassign_station_dids
    if current_user.is_marketer?

      @station = DataGateway.find params[:data_gateway_id]

      @entryways = @station.data_entryways.page(1).per(DIDS_PAGE_SIZE)
      success_save = false
      if params[:selected_dids]
        @selected_entry_ids = params[:selected_dids].uniq
        selected_entryways = DataEntryway.where(:id => @selected_entry_ids)
        selected_entryways.each do |entryway|
          entryway.gateway_id = nil
          success_save = entryway.save
        end
      end
      if success_save
        data_entryway = ''
        @selected_entry_ids.each do |entryway_id|
          entryway = DataEntryway.find(entryway_id)
          if entryway
            data_entryway += ' ' + entryway.did_e164
          end
        end
        @station.create_activity key: 'data_gateway.destroy_entryway', owner: current_user, params: {:entryway => @selected_entry_ids },
          trackable_title: @station.title, user_title: user_title, 
          sec_trackable_title: data_entryway, sec_trackable_type: 'DataEntryway'
      end
      respond_to do |format|
        format.js {render "settings/dids/unassign_station_dids"}
      end

    end

  end

  #==========================================================================
  # Method: get
  # Parameters:
  # + name:, format:
  # Responses:
  #   - dids_scroll.js.haml
  # Description: 
  #   - DIDs section scroll in extension page
  #   - This is an endless scroll
  # Notes:
  #==========================================================================
  def dids_scroll
    if !params[:page].present?
      @page = 1
    else
      @page = params[:page]
    end

    @station_id = params[:data_gateway_id]
    if @station_id
      @station = DataGateway.find @station_id
      @entryways = @station.data_entryways.page(params[:page]).per(DIDS_PAGE_SIZE)

      respond_to do |format|
        format.js {render "settings/dids/dids_scroll"}
      end
    end
  end

  def search_stream_name
    query = params[:query]
    render :json => DataContent.search_by_stream_name(query).map(&:title)
  end
  
end
