#-------------------------------------------------------------------------------
# For Users, User Permissions
#-------------------------------------------------------------------------------
puts "Sample data........."
admin_permission = SysUserPermission.find_by_title("Super Admin")

# For rca permission
rca_permission = SysUserPermission.find_by_title("Rca User")

# For 3rdparty permission
thirdparty_permission = SysUserPermission.find_by_title("Thirdparty User")

# For broadcast permission
broadcast_permission = SysUserPermission.find_by_title("Broadcast User")

rca_1 = rca_permission.users.create({
  email: "rca1@zenoradio.com",
  password: "1234qwer",
  password_confirmation: "1234qwer",
  enabled: true
})

rca_2 = rca_permission.users.create({
  email: "rca2@zenoradio.com", 
  password: "1234qwer",
  password_confirmation: "1234qwer",
  enabled: true
})

thirdparty_1 = thirdparty_permission.users.create({
  email: "3rdparty1@zenoradio.com", 
  password: "1234qwer",
  password_confirmation: "1234qwer",
  enabled: true
})

thirdparty_2 = thirdparty_permission.users.create({
  email: "3rdparty2@zenoradio.com",
  password: "1234qwer",
  password_confirmation: "1234qwer",
  enabled: true
})

broadcast_1 = broadcast_permission.users.create({
  email: "broadcast1@zenoradio.com",
  password: "1234qwer",
  password_confirmation: "1234qwer",
  enabled: true
})

broadcast_2 = broadcast_permission.users.create({
  email: "broadcast2@zenoradio.com",
  password: "1234qwer",
  password_confirmation: "1234qwer",
  enabled: true
})

# For test my account page
admin_test = User.create({
  email: "admin_test@zenoradio.com",
  password: "1234qwer",
  permission_id: admin_permission.id,
  password_confirmation: "1234qwer",
  enabled: true
})

rca_permission.users.create({
  email: "rca1_test@zenoradio.com",
  password: "1234qwer",
  password_confirmation: "1234qwer",
  enabled: true
})

rca_permission.users.create({
  email: "rca2_test@zenoradio.com", 
  password: "1234qwer",
  password_confirmation: "1234qwer",
  enabled: true
})

thirdparty_1 = thirdparty_permission.users.create({
  email: "3rdparty1_test@zenoradio.com", 
  password: "1234qwer",
  password_confirmation: "1234qwer",
  enabled: true
})

thirdparty_permission.users.create({
  email: "3rdparty2_test@zenoradio.com",
  password: "1234qwer",
  password_confirmation: "1234qwer",
  enabled: true
  
})

broadcast_permission.users.create({
  email: "broadcast1_test@zenoradio.com",
  password: "1234qwer",
  password_confirmation: "1234qwer",
  enabled: true
})

broadcast_permission.users.create({
  email: "broadcast2_test@zenoradio.com",
  password: "1234qwer",
  password_confirmation: "1234qwer",
  enabled: true
})
data_group_rca = DataGroupRca.create(title: "Data Group Rca 1")
data_group_rca1= DataGroupRca.create(title: "Data Group Rca 2")

SysUserResourceRca.create({rca_id:data_group_rca.id, user_id: rca_1.id})
SysUserResourceRca.create({rca_id:data_group_rca.id, user_id: rca_2.id})

data_group_thirdparty = DataGroup3rdparty.create(title: "Data Group Thirdparty 1")
SysUserResource3rdparty.create({"3rdparty_id" => data_group_thirdparty.id, user_id: thirdparty_1.id})
SysUserResource3rdparty.create({"3rdparty_id" => data_group_thirdparty.id, user_id: thirdparty_2.id})

data_group_broadcast = DataGroupBroadcast.create(title: "Data Group Broadcast 1")
SysUserResourceBroadcast.create({broadcast_id:data_group_broadcast.id, user_id: broadcast_1.id})
SysUserResourceBroadcast.create({broadcast_id:data_group_broadcast.id, user_id: broadcast_2.id})

us_language = DataGroupLanguage.find_by_title("American")
vn_language = DataGroupLanguage.find_by_title("VietNamese")
me_language = DataGroupLanguage.find_by_title("Mexican")
ca_language = DataGroupLanguage.find_by_title("Canadan")

us = DataGroupCountry.where("iso_alpha_2" => 'us').first #US
vn = DataGroupCountry.where("iso_alpha_2" => 'vn').first #Vietnam
me = DataGroupCountry.where("iso_alpha_2" => 'mx').first #Mexico
ca = DataGroupCountry.where("iso_alpha_2" => 'ca').first #Canada

#-------------------------------------------------------------------------------
# For Data Content, Entryway, Gateway
#-------------------------------------------------------------------------------
content_1 = DataContent.create({
  title: "Content 1",
  broadcast_id: data_group_broadcast.id,
  country_id: us.id,
  language_id: us_language.id,
  genre_id: DataGroupGenre.all.sample.id,
  media_type: "M Content 1",
  media_url: "http://zenoradio.com/content_1"
})

content_2 = DataContent.create({
  title: "Content 2",
  broadcast_id: data_group_broadcast.id,
  country_id: us.id,
  language_id: us_language.id,
  genre_id: DataGroupGenre.all.sample.id,
  media_type: "M Content 2",
  media_url: "http://zenoradio.com/content_2"
})

list_countries = [[vn, vn_language], [me, me_language], [ca, ca_language]]
10.times do |t|
  current = list_countries.sample
  DataContent.create({
    title: "Content #{3 + t}",
    broadcast_id: data_group_broadcast.id,
    country_id: current[0].id,
    language_id: current[1].id,
    genre_id: DataGroupGenre.all.sample.id,
    media_type: "M Content #{3 + t}",
    media_url: "http://zenoradio.com/content_#{3 + t}"
  })
end

gateway_1 = DataGateway.create({
  title: "Gateway 1",
  country_id: us.id,
  language_id: us_language.id,
  broadcast_id: data_group_broadcast.id,
  rca_id: data_group_rca.id
})

gateway_2 = DataGateway.create({
  title: "Gateway 2",
  country_id: us.id,
  language_id: us_language.id,
  broadcast_id: data_group_broadcast.id,
  rca_id: data_group_rca.id
})

gateway_3 = DataGateway.create({
  title: "Gateway 3",
  country_id: vn.id,
  language_id: vn_language.id,
  broadcast_id: data_group_broadcast.id,
  rca_id: data_group_rca.id
})

gateway_4 = DataGateway.create({
  title: "Gateway 4",
  country_id: vn.id,
  language_id: vn_language.id,
  broadcast_id: data_group_broadcast.id,
  rca_id: data_group_rca.id
})
40.times do |j|
  gateway_5 = DataGateway.create({
    title: "Gateway #{5 + j}",
    country_id: vn.id,
    language_id: vn_language.id,
    broadcast_id: data_group_broadcast.id,
    rca_id: data_group_rca1.id
  })
end
content_1.data_gateway_conferences.create({gateway_id: gateway_1.id, extension: "for C1 & G1"})
content_1.data_gateway_conferences.create({gateway_id: gateway_2.id, extension: "for C1 & G2"})
content_1.data_gateway_conferences.create({gateway_id: gateway_3.id, extension: "for C1 & G3"})

content_2.data_gateway_conferences.create({gateway_id: gateway_1.id, extension: "for C2 & G1"})
content_2.data_gateway_conferences.create({gateway_id: gateway_2.id, extension: "for C2 & G2"})
content_2.data_gateway_conferences.create({gateway_id: gateway_4.id, extension: "for C2 & G4"})

provider_1 = DataEntrywayProvider.create({title: "Provider 1"})
provider_2 = DataEntrywayProvider.create({title: "Provider 2"})

entry_1 = DataEntryway.create({
  title: "Entryway 1",
  did_e164: "12120001111",
  gateway_id: gateway_1.id,
  country_id: gateway_1.data_group_country.id,
  "3rdparty_id" => data_group_thirdparty.id,
  entryway_provider: provider_1.id
})

entry_1_bis = DataEntryway.create({
  title: "Entryway 1 Bis",
  did_e164: "12120002222",
  gateway_id: gateway_1.id,
  country_id: gateway_1.data_group_country.id,
  "3rdparty_id" => data_group_thirdparty.id,
  entryway_provider: provider_1.id
})

entry_2 = DataEntryway.create({
  title: "Entryway 2",
  did_e164: "12120003333",
  gateway_id: gateway_2.id,
  country_id: gateway_2.data_group_country.id,
  "3rdparty_id" => data_group_thirdparty.id,
  entryway_provider: provider_1.id
})

entry_2_bis = DataEntryway.create({
  title: "Entryway 2 Bis",
  did_e164: "12120004444",
  gateway_id: gateway_2.id,
  country_id: gateway_2.data_group_country.id,
  "3rdparty_id" => data_group_thirdparty.id,
  entryway_provider: provider_1.id
})

entry_3 = DataEntryway.create({
  title: "Entryway 3",
  did_e164: "12120005555",
  gateway_id: gateway_3.id,
  country_id: gateway_3.data_group_country.id,
  "3rdparty_id" => data_group_thirdparty.id,
  entryway_provider: provider_1.id
})

entry_3_bis = DataEntryway.create({
  title: "Entryway 3 Bis",
  did_e164: "12120006666",
  gateway_id: gateway_3.id,
  country_id: gateway_3.data_group_country.id,
  "3rdparty_id" => data_group_thirdparty.id,
  entryway_provider: provider_1.id
})

entry_4 = DataEntryway.create({
  title: "Entryway 4",
  did_e164: "12120007777",
  gateway_id: gateway_4.id,
  country_id: gateway_4.data_group_country.id,
  "3rdparty_id" => data_group_thirdparty.id,
  entryway_provider: provider_2.id
})

entry_4_bis = DataEntryway.create({
  title: "Entryway 4 Bis",
  did_e164: "12120008888",
  gateway_id: gateway_4.id,
  country_id: gateway_4.data_group_country.id,
  "3rdparty_id" => data_group_thirdparty.id,
  entryway_provider: provider_2.id
})

#unused entryways
100.times do |t|
  DataEntryway.create({
    title: "Entryway #{9 + t}",
    did_e164: (12120009000 + t).to_s,
    country_id: gateway_4.data_group_country.id,
    "3rdparty_id" => data_group_thirdparty.id,
    entryway_provider: provider_2.id
  })
end



#-------------------------------------------------------------------------------
# For Summary Sessions
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# For SummarySessionsByEntryway
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# For Data Listener, DataListenerAniCarrier
#-------------------------------------------------------------------------------
listener_1 = DataListener.create({
  title: "Listener 1",
  area_code: "205"
})
listener_2 = DataListener.create({
  title: "Listener 2",
  area_code: "205"
})
listener_4 = DataListener.create({
  title: "Listener 4",
  area_code: "907"
})
listener_3 = DataListener.create({
  title: "Listener 3",
  area_code: "907"
})

data_listener_ani_carrier_1 = DataListenerAniCarrier.create({
  title: "Data Listener Ani Carrier 1"
})
data_listener_ani_carrier_2 = DataListenerAniCarrier.create({
  title: "Data Listener Ani Carrier 2"
})
data_listener_ani_carrier_3 = DataListenerAniCarrier.create({
  title: "Data Listener Ani Carrier 3"
})

listener_1.data_listener_anis.create({carrier_id: data_listener_ani_carrier_1.id, ani_e164: Faker::Base.regexify(/[0-9]{11}/)})
listener_1.data_listener_anis.create({carrier_id: data_listener_ani_carrier_2.id, ani_e164: Faker::Base.regexify(/[0-9]{11}/)})

listener_2.data_listener_anis.create({carrier_id: data_listener_ani_carrier_1.id, ani_e164: Faker::Base.regexify(/[0-9]{11}/)})
listener_2.data_listener_anis.create({carrier_id: data_listener_ani_carrier_3.id, ani_e164: Faker::Base.regexify(/[0-9]{11}/)})

listener_3.data_listener_anis.create({carrier_id: data_listener_ani_carrier_1.id, ani_e164: Faker::Base.regexify(/[0-9]{11}/)})
listener_3.data_listener_anis.create({carrier_id: data_listener_ani_carrier_2.id, ani_e164: Faker::Base.regexify(/[0-9]{11}/)})
listener_3.data_listener_anis.create({carrier_id: data_listener_ani_carrier_3.id, ani_e164: Faker::Base.regexify(/[0-9]{11}/)})

listener_4.data_listener_anis.create({carrier_id: data_listener_ani_carrier_3.id, ani_e164: Faker::Base.regexify(/[0-9]{11}/)})

#-------------------------------------------------------------------------------
# For Summary call
#-------------------------------------------------------------------------------
40.times do |time|
  SummaryCall.create({
    date: DateTime.now - time.days,
    entryway_id: entry_1.id,
    listener_ani_carrier_id: data_listener_ani_carrier_1.id,
    count: [1,2,3,4,5].sample,
    seconds: Random.new.rand(10..2000)

  })

  SummaryCall.create({
    date: DateTime.now - time.days,
    entryway_id: entry_2.id,
    listener_ani_carrier_id: data_listener_ani_carrier_1.id,
    count: [1,2,3,4,5].sample,
    seconds: Random.new.rand(10..2000)

  })
end

#-------------------------------------------------------------------------------
# For Summary listen
#-------------------------------------------------------------------------------
40.times do |time|
  SummaryListen.create({
    date: DateTime.now - time.days,
    entryway_id: entry_1.id,
    gateway_id: gateway_1.id,
    content_id: content_1.id, 
    count: [1,2,3,4,5].sample,
    count_acd_10sec: [1,2,3].sample, 
    count_acd_1min: [1,2,3].sample, 
    count_acd_5min: [1,2,3].sample, 
    count_acd_20min: [1,2,3].sample, 
    count_acd_1hr: [1,2,3].sample, 
    count_acd_2hr: [1,2,3].sample,
    count_acd_6hr: [1,2,3].sample,
    count_acd_more6hr: [1,2,3].sample,
    seconds: Random.new.rand(10..2000)

  })


end

#-------------------------------------------------------------------------------
# For Data Listener At Gateway
#-------------------------------------------------------------------------------
listener_1.data_listener_at_entryways.create({
  context_at_id: entry_1.id,
  statistics_first_session_date: DateTime.now
})

listener_1.data_listener_at_entryways.create({
  context_at_id: entry_2.id,
  statistics_first_session_date: DateTime.now
})

listener_1.data_listener_at_entryways.create({
  context_at_id: entry_3.id,
  statistics_first_session_date: DateTime.now
})

listener_1.data_listener_at_entryways.create({
  context_at_id: entry_4.id,
  statistics_first_session_date: DateTime.now
})

listener_2.data_listener_at_entryways.create({
  context_at_id: entry_1_bis.id,
  statistics_first_session_date: DateTime.now
})
listener_2.data_listener_at_entryways.create({
  context_at_id: entry_2_bis.id,
  statistics_first_session_date: DateTime.now
})
listener_2.data_listener_at_entryways.create({
  context_at_id: entry_3_bis.id,
  statistics_first_session_date: DateTime.now
})
listener_2.data_listener_at_entryways.create({
  context_at_id: entry_4_bis.id,
  statistics_first_session_date: DateTime.now
})

listener_3.data_listener_at_entryways.create({
  context_at_id: entry_1_bis.id,
  statistics_first_session_date: DateTime.now
})

listener_3.data_listener_at_entryways.create({
  context_at_id: entry_1_bis.id,
  statistics_first_session_date: DateTime.now
})

listener_4.data_listener_at_entryways.create({
  context_at_id: entry_2.id,
  statistics_first_session_date: DateTime.now
})

listener_4.data_listener_at_entryways.create({
  context_at_id: entry_2_bis.id,
  statistics_first_session_date: DateTime.now
})
#-------------------------------------------------------------------------------
# For Data Listener At Gateway
#-------------------------------------------------------------------------------
listener_1.data_listener_at_gateways.create({
  context_at_id: gateway_1.id,
  statistics_first_session_date: DateTime.now
})

listener_1.data_listener_at_gateways.create({
  context_at_id: gateway_2.id,
  statistics_first_session_date: DateTime.now
})

listener_1.data_listener_at_gateways.create({
  context_at_id: gateway_3.id,
  statistics_first_session_date: DateTime.now
})

listener_1.data_listener_at_gateways.create({
  context_at_id: gateway_4.id,
  statistics_first_session_date: DateTime.now
})

listener_2.data_listener_at_gateways.create({
  context_at_id: gateway_1.id,
  statistics_first_session_date: DateTime.now
})

listener_2.data_listener_at_gateways.create({
  context_at_id: gateway_2.id,
  statistics_first_session_date: DateTime.now
})

listener_2.data_listener_at_gateways.create({
  context_at_id: gateway_3.id,
  statistics_first_session_date: DateTime.now
})

listener_2.data_listener_at_gateways.create({
  context_at_id: gateway_4.id,
  statistics_first_session_date: DateTime.now
})

listener_3.data_listener_at_gateways.create({
  context_at_id: gateway_1.id,
  statistics_first_session_date: DateTime.now
})

listener_3.data_listener_at_gateways.create({
  context_at_id: gateway_2.id,
  statistics_first_session_date: DateTime.now
})

listener_4.data_listener_at_gateways.create({
  context_at_id: gateway_3.id,
  statistics_first_session_date: DateTime.now
})

listener_4.data_listener_at_gateways.create({
  context_at_id: gateway_4.id,
  statistics_first_session_date: DateTime.now
})

#-------------------------------------------------------------------------------
# For Data Listener At Content
#-------------------------------------------------------------------------------
listener_1.data_listener_at_contents.create({
  context_at_id: content_1.id,
  statistics_first_session_date: DateTime.now
})

listener_1.data_listener_at_contents.create({
  context_at_id: content_2.id,
  statistics_first_session_date: DateTime.now
})

listener_2.data_listener_at_contents.create({
  context_at_id: content_1.id,
  statistics_first_session_date: DateTime.now
})

listener_2.data_listener_at_contents.create({
  context_at_id: content_2.id,
  statistics_first_session_date: DateTime.now
})

listener_3.data_listener_at_contents.create({
  context_at_id: content_1.id,
  statistics_first_session_date: DateTime.now
})

listener_3.data_listener_at_contents.create({
  context_at_id: content_2.id,
  statistics_first_session_date: DateTime.now
})

listener_4.data_listener_at_contents.create({
  context_at_id: content_1.id,
  statistics_first_session_date: DateTime.now
})

listener_4.data_listener_at_contents.create({
  context_at_id: content_2.id,
  statistics_first_session_date: DateTime.now
})

#-------------------------------------------------------------------------------
# For Summary Listener by Entryway
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# For Summary Listener by Entryway 3rdparty
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# For Summary Listener by Gateway
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# For Summary Listener by Gateway Broadcast
#------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# For Summary Listener by Gateway Rca
#------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# For Summary Listener by Content
#------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# For Summary Listener by Content broadcash
#------------------------------------------------------------------------------

10.times do |t|
  log_call_1 = LogCall.create({
    date_start: DateTime.now - t.days,
    date_stop: DateTime.now - t.days,
    ani_e164: listener_1.data_listener_anis.first.ani_e164,
    listener_ani_id: listener_1.data_listener_anis.first.id,
    listener_id: listener_1.id,
    gateway_id: gateway_1.id,
    did_e164: entry_1.did_e164,
    entryway_id: entry_1.id,
    seconds: 100 + (t + 1).days
  })
  
  log_call_1_bis = LogCall.create({
    date_start: DateTime.now - t.days,
    date_stop: DateTime.now - t.days,
    ani_e164: listener_1.data_listener_anis.first.ani_e164,
    listener_ani_id: listener_1.data_listener_anis.first.id,
    listener_id: listener_1.id,
    gateway_id: gateway_1.id,
    did_e164: entry_1_bis.did_e164,
    entryway_id: entry_1_bis.id,
    seconds: 100 + (t + 1).days
  })
  # For logListen
  LogListen.create({
    date_start: DateTime.now - t.days,
    date_stop: DateTime.now - t.days,
    log_call_id: log_call_1.id,
    content_id: gateway_1.data_gateway_conferences.first.content_id,
    gateway_conference_id: gateway_1.data_gateway_conferences.first.id,
    seconds: (100 + (t + 1).days)/2
  })
  LogListen.create({
    date_start: DateTime.now - t.days,
    date_stop: DateTime.now - t.days,
    log_call_id: log_call_1_bis.id,
    content_id: gateway_1.data_gateway_conferences.last.content_id,
    gateway_conference_id: gateway_1.data_gateway_conferences.last.id,
    seconds: (100 + (t + 1).days)/2
  })
  log_call_2 = LogCall.create({
    date_start: DateTime.now - t.days,
    date_stop: DateTime.now - t.days,
    ani_e164: listener_2.data_listener_anis.first.ani_e164,
    listener_ani_id: listener_2.data_listener_anis.first.id,
    listener_id: listener_2.id,
    gateway_id: gateway_2.id,
    did_e164: entry_2.did_e164,
    entryway_id: entry_2.id,
    seconds: 200 + (t + 1).days
  })

  log_call_2_bis = LogCall.create({
    date_start: DateTime.now - t.days,
    date_stop: DateTime.now - t.days,
    ani_e164: listener_2.data_listener_anis.first.ani_e164,
    listener_ani_id: listener_2.data_listener_anis.first.id,
    listener_id: listener_2.id,
    gateway_id: gateway_2.id,
    did_e164: entry_2_bis.did_e164,
    entryway_id: entry_2_bis.id,
    seconds: 200 + (t + 1).days
  })
  # For logListen
  log_listen_1 = LogListen.create({
    date_start: DateTime.now - t.days,
    date_stop: DateTime.now - t.days,
    log_call_id: log_call_2.id,
    content_id: gateway_2.data_gateway_conferences.first.content_id,
    gateway_conference_id: gateway_2.data_gateway_conferences.first.id,
    seconds: (200 + (t + 1).days)/2
  })
  LogListen.create({
    date_start: DateTime.now - t.days,
    date_stop: DateTime.now - t.days,
    log_call_id: log_call_2_bis.id,
    content_id: gateway_2.data_gateway_conferences.last.content_id,
    gateway_conference_id: gateway_2.data_gateway_conferences.last.id,
    seconds: (200 + (t + 1).days)/2
  })
  log_call_3  = LogCall.create({
    date_start: DateTime.now - t.days,
    date_stop: DateTime.now - t.days,
    ani_e164: listener_3.data_listener_anis.first.ani_e164,
    listener_ani_id: listener_3.id,
    listener_id: listener_3.id,
    gateway_id: gateway_3.id,
    did_e164: entry_3.did_e164,
    entryway_id: entry_3.id,
    seconds: 300 + (t + 1).days
  })

  log_call_3_bis = LogCall.create({
    date_start: DateTime.now - t.days,
    date_stop: DateTime.now - t.days,
    ani_e164: listener_3.data_listener_anis.first.ani_e164,
    listener_ani_id: listener_3.data_listener_anis.first.id,
    listener_id: listener_3.id,
    gateway_id: gateway_3.id,
    did_e164: entry_3_bis.did_e164,
    entryway_id: entry_3_bis.id,
    seconds: 300 + (t + 1).days
  })
  # For logListen
  LogListen.create({
    date_start: DateTime.now - t.days,
    date_stop: DateTime.now - t.days,
    log_call_id: log_call_3.id,
    content_id: gateway_3.data_gateway_conferences.first.content_id,
    gateway_conference_id: gateway_3.data_gateway_conferences.first.id,
    seconds: (300 + (t + 1).days)/2
  })
  LogListen.create({
    date_start: DateTime.now - t.days,
    date_stop: DateTime.now - t.days,
    log_call_id: log_call_3_bis.id,
    content_id: gateway_3.data_gateway_conferences.last.content_id,
    gateway_conference_id: gateway_3.data_gateway_conferences.last.id,
    seconds: (300 + (t + 1).days)/2
  })
  log_call_4 = LogCall.create({
    date_start: DateTime.now - t.days,
    date_stop: DateTime.now - t.days,
    ani_e164: listener_4.data_listener_anis.first.ani_e164,
    listener_ani_id: listener_4.data_listener_anis.first.id,
    listener_id: listener_4.id,
    gateway_id: gateway_4.id,
    did_e164: entry_4.did_e164,
    entryway_id: entry_4.id,
    seconds: 400 + (t + 1).days
  })

  log_call_4_bis = LogCall.create({
    date_start: DateTime.now - t.days,
    date_stop: DateTime.now - t.days,
    ani_e164: listener_4.data_listener_anis.first.ani_e164,
    listener_ani_id: listener_4.data_listener_anis.first.id,
    listener_id: listener_4.id,
    gateway_id: gateway_4.id,
    did_e164: entry_4_bis.did_e164,
    entryway_id: entry_4_bis.id,
    seconds: 400 + (t + 1).days
  })
  # For logListen
  LogListen.create({
    date_start: DateTime.now - t.days,
    date_stop: DateTime.now - t.days,
    log_call_id: log_call_4.id,
    content_id: gateway_4.data_gateway_conferences.first.content_id,
    gateway_conference_id: gateway_4.data_gateway_conferences.first.id,
    seconds: (400 + (t + 1).days)/2
  })
  LogListen.create({
    date_start: DateTime.now - t.days,
    date_stop: DateTime.now - t.days,
    log_call_id: log_call_4_bis.id,
    content_id: gateway_4.data_gateway_conferences.last.content_id,
    gateway_conference_id: gateway_4.data_gateway_conferences.last.id,
    seconds: (400 + (t + 1).days)/2
  })


  # For NowSession
  NowSession.create({
    log_call_id: log_call_1.id,
    log_listen_id: log_listen_1.id,
    call_server_id: 161101,
    call_date_start: DateTime.now - t.days,
    call_ani_e164: listener_1.data_listener_anis.first.ani_e164,
    call_did_e164: entry_1.did_e164,
    call_listener_play_welcome: 0,
    call_listener_ani_id: listener_1.data_listener_anis.first.id,
    call_listener_id: listener_1.id,
    call_listener_is_anonymous: 0,
    call_entryway_id: entry_1.id,
    call_gateway_id: entry_1.data_gateway.id,
    listen_active: 0,
    listen_date_start: 0,
    listen_extension: 2,
    listen_content_id: gateway_1.data_gateway_conferences.first.content_id,
    listen_gateway_conference_id: gateway_1.data_gateway_conferences.first.id,
    listen_server_id: 161101
  })

end

10.times do |t|
  a = DataGatewayPrompt.new(title: "Prompt #{t + 1}")
  a.build_data_gateway_prompt_blob
  a.gateway_id = gateway_1.id
  a.save
end

puts "Done!"
