class MapsController < ApplicationController
  def render_map
    map = ListenerMap.new(current_user)
    render :json => map.get_map_of_listeners
  end
end
