class ListenerMap
  def initialize(user)
    @user = user
  end

  def area_code_for_listener(listener)
    return nil unless listener.length == 11 && listener =~ /^1/
    listener.slice(1,3)
  end

  def extract_area_code(phone_list)
    phone_list.map{|number| area_code_for_listener(number)}.compact unless phone_list.nil?
  end

  def format_phone_listeners(listeners)
    results = []
    positions = {}
    AreaCodes.where(area_code: listeners).group("area_code").find_each do |i|
      positions[i.area_code] = {lat: i.latitude, long: i.longitude}
    end
    listeners.each do |x|
      if positions[x].present?
        results << {lat: positions[x][:lat], long: positions[x][:long]}
      end
    end
    {:results => results, :phone_listeners => results.length}
  end

  def convert_ip_lat_long(ip)
    @geoip ||= GeoIP.new("app/assets/GeoLiteCity.dat")
    @geoip.city(ip)
  end

  def format_widget_listeners(ip_list)
    results = []
    ip_list.each do |ip|
      a = convert_ip_lat_long(ip)
      if a.present?
        results << {lat: a.latitude, long: a.longitude}
      end
    end
    {:results => results, :widget_listeners => results.present? ? results.length : 0}
  end

########App Listeners#################
# def format_app_listeners_for_gmaps(listeners)
#   results = []
#   listeners.each do |ip|
#     a = convert_ip_lat_long(ip)
#     results << {lat: a.latitude.to_f, long: a.longitude.to_f} unless a.nil?
#   end
#   {:results => results, :app_listeners => results.length}
# end
###################################

  def get_map_of_listeners
    if @user.present?
      phone_hash = format_phone_listeners(extract_area_code(@user.get_phone_listeners))
      widget_hash = format_widget_listeners(@user.get_widget_listeners)
      #app_hash = format_app_listeners_for_gmaps(user.get_app_listeners)

      {results: widget_hash[:results] + phone_hash[:results],
      phone_listeners: phone_hash[:phone_listeners],
      widget_listeners: widget_hash[:widget_listeners],}
    else
      {results: [], phone_listeners: 0, widget_listeners: 0}
    end
  end

end