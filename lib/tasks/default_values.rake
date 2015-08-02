task :refresh => :environment do
  puts "Generate 5 pending users"
  (1..5).each do |idx|
    size = PendingUser.count + idx
    user = PendingUser.new
    user.station_name = "station name #{size}"
    user.company_name = "company name #{size}"
    user.streaming_url = "streaming url #{size}"
    user.name = "name #{size}"
    user.email = "test#{size}@pendingusers.com"
    user.website = "Website #{size}"
    user.language = "Language #{size}"
    user.phone = "Phone #{size}"
    user.facebook = "Facebook #{size}"
    user.twitter = "Twitter #{size}"
    user.address = "Address #{size}"
    user.city = "City #{size}"
    user.state = "State #{size}"
    user.country = "Country #{size}"
    user.genre = "Genre #{size}"
    user.affiliate = "Affiliate #{size}"
    user.rca = "RCA #{size}"
    user.signup_date = Date.today
    user.save
  end

  DataGateway.all do |data|
    data.logo = nil 
    data.save(validate: false)
  end 
end