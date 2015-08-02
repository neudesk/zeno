namespace :reachout do
  desc "Creating config for setting up default DID for reachout campaign creation."
  task :create_default_did_config => :environment do
    primary_config = AdminSetting.find_or_create_by_name(name: 'primary_campaign_default_did_provider')
    primary_config.value = 'FCC/Pineridge'
    if primary_config.save
      puts 'FCC/Pineridge is set as primary default DID config is created'
    end
    secondary_config = AdminSetting.find_or_create_by_name(name: 'secondary_campaign_default_did_provider')
    secondary_config.value = 'FCC/Breda'
    if secondary_config.save
      puts 'FCC/Breda is set as secondary default DID config is created'
    end
  end

  desc "Set value to covered listeners timeframe by month settings"
  task :set_listeners_job_config => :environment do
    config = AdminSetting.find_or_create_by_name(name: 'covered_listeners_timeframe_by_month')
    config.value = 3
    if config.save
      puts 'Settings covered_listeners_timeframe_by_month has been set.'
    end
  end

end