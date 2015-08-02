class MyRadioController < ApplicationController
  before_filter :authenticate_user!

  #==========================================================================
  # Method: get
  # Parameters:
  # + name:, format:
  # Responses:
  #  - station.js.haml
  # Description: Loading Tags tab for settings page
  # Notes: 
  #==========================================================================
  def station
    @station = params[:id].present? ? DataGateway.find(params[:id]) : @stations[0]
    @extensions = DataGatewayConference.joins(:data_content)
                                        .where(gateway_id:@station.id)
                                         .select("data_content.id,
                                                 data_content.country_id, data_content.language_id, data_content.genre_id,
                                                 data_content.title,
                                                 data_gateway_conference.id as extension_id, 
                                                 data_gateway_conference.extension as extension").order("data_gateway_conference.extension*1")
  
    @countries = DataGroupCountry.order(:title)
    @languages = DataGroupLanguage.all
    @genres = DataGroupGenre.order(:title)
    respond_to do |format|
      format.js
    end

  end

  #==========================================================================
  # Method: put
  # Parameters:
  # + name:, format:
  # Responses:
  #  - update_station.js.haml
  # Description: Update station (Settings page> Tags tab)
  # Notes: 
  #==========================================================================
  def update_station
    @station = DataGateway.find(params[:id])
    @countries = DataGroupCountry.order(:title)
    @languages = DataGroupLanguage.all
    @genres = DataGroupGenre.all
    @extensions = DataGatewayConference.joins(:data_content)
                                       .where(gateway_id:@station.id)
                                        .select("data_content.id,
                                                data_content.country_id, data_content.language_id, data_content.genre_id,
                                                data_content.title,
                                                data_gateway_conference.id as extension_id, 
                                                data_gateway_conference.extension as extension").order("data_gateway_conference.extension*1")

    old_rca = @station.rca_id
    success_update = @station.update_attributes(params[:data_gateway])
    new_rca = @station.rca_id
    if success_update
      if old_rca != new_rca
        if new_rca.nil?
          @station.create_activity key: 'data_gateway.untag_rca', owner: current_user, parameters: {:old_rca => old_rca, :new_rca => new_rca },
            trackable_title: @station.title, user_title: user_title, 
            sec_trackable_title: DataGroupRca.find(old_rca).title, sec_trackable_type: 'DataGroupRca'
        else
          @station.create_activity key: 'data_gateway.tag_rca', owner: current_user, parameters: {:old_rca => old_rca, :new_rca => new_rca },
            trackable_title: @station.title, user_title: user_title, 
            sec_trackable_title: DataGroupRca.find(new_rca).title, sec_trackable_type: 'DataGroupRca'
        end
      end
      flash.now[:notice] = "Updated successfully."
    else
      flash.now[:notice] = @station.errors.full_messages.join('and')
    end

    respond_to do |format|
      format.js {render "my_radio/station"}
    end

    # redirect_to settings_path(station_id: @station.id, slider_search_enabled: @slider_search_enabled, query: @slider_query, country_id: @slider_country_id, rca_id: @slider_rca_id)
  end


end
