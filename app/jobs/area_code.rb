class AreaCode < Struct.new(:param)
  def perform 
  result = AreaCodes.all 
  insert_values = []
  result.each do |res|
    if res['area_code'].length > 3
     area_codes = res['area_code'].split(',')
     area_codes.each do |a|
       insert_values << {:state => res['state'], :area_code => a, :latitude => res['latitude'], :longitude => res['longitude']}
     end
     res.destroy
    end
  end
  AreaCodes.create(insert_values)
  end
end