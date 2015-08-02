def create_listener
  listener = Listener.new(area_code: Faker::Base.regexify(/[0-9]{3}/), name: Faker::Name.name, phone: Faker::PhoneNumber.phone_number)
  listener.save(validate: false)
  listener
end

def build_gateway_with_constrained_data(name, language, country)
  gw = create(:gateway, name: name, language: language, country: country)
  enw = gw.entryways.build(name: "Entryway A", :did => Faker::Base.regexify(/[0-9]{7}/), :provider => Faker::Name.name)
  3.times do |j|
    cont = gw.contents.build(name: "Content #{j} of #{name}", language: language, country: country)
    ext = cont.build_extension(name: "Extenstion of Content #{j} of #{name}")
    gw.listener_entryways.build(listener:create_listener, extension:ext, called_at:(Time.now + 3.days), content:cont, entryway:enw)
  end

  gw
end
