class StationsController < ApplicationController
  before_filter :set_station, except: [:index]
  def index
    @stations = current_user.stations
    @q = @stations.search(params[:q])
    @stations = @q.result(distinct: true).page(params[:page]).per(15)
  end

  def show
    @streams =  @station.data_contents
    @phone_numbers = @station.data_entryways
  end

  def set_station
    @station = current_user.stations.find_by_id(params[:id])
    redirect_to root_url, alert: "Not Authorized." unless @station.present?
  end

end
