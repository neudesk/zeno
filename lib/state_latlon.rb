require 'csv'
class StateLatlon 
  def self.regions
    regions = {}
    zip_path = File.open(File.join(Rails.root, 'data', 'state_latlon.csv'))
    @zip_codes = CSV.read(zip_path)
    @zip_codes.delete_at 0
    @zip_codes.map {|row|
      regions[row[0]] = row.slice(1,2)
    }
    return regions
  end 
end