module TrackingUsersHelper
  def timeago(time, options = {})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.getutc.iso8601)) if time
  end
  
  def link_to_settings_station(station_id, options = {})
    options[:class] ||= "settings_station"
    station = DataGateway.find(station_id)
    if station
      href = "/settings?gateway_id=" + station.id.to_s + "&query=" + station.title
      content_tag(:a, :href => href, :title => station.title ) do
        station.title
      end        
    end
  end
end
