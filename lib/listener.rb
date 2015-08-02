module Listener 
  def gmaps4rails_address
    #describe how to retrieve the address from your model, if you use directly a db column, you can dry your code, see wiki
  end

  def longitude
    location.last
  end

  def latitude 
    location.first
  end 

  def location
    return StateLatlon.regions[region] || []
  end

  def region
    area_code.to_region 
  end 

  def state_name region 
    madison = Madison.new 
    madison.get_name region 
  end 
  
end

# == Schema Information
#
# Table name: listeners
#
#  id        :integer          not null, primary key
#  area_code :integer
#

