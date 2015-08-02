campaigns_logfile = File.open("#{Rails.root}/log/campaigns.log", 'a')
campaigns_logfile.sync = true
CAMPAIGNS_LOG = CampaignsLogger.new(campaigns_logfile)

didwatch_logfile = File.open("#{Rails.root}/log/didwatch.log", 'a')
didwatch_logfile.sync = true
DIDWATCH_LOG = DidwatchLogger.new(didwatch_logfile)

sendcampaign_logfile = File.open("#{Rails.root}/log/schedule_campaign.log", 'a')
sendcampaign_logfile.sync = true
SCHEDULE_CAMPAIGN_LOG = ScheduleCampaignLogger.new(sendcampaign_logfile)

get_campaign_statistic_log = File.open("#{Rails.root}/log/get_campaign_statistics.log", 'a')
get_campaign_statistic_log.sync = true
GET_CAMPAIGN_STATISTICS_LOG = ScheduleCampaignLogger.new(get_campaign_statistic_log)

auto_delete_campaign = File.open("#{Rails.root}/log/auto_delete_campaign.log", 'a')
auto_delete_campaign.sync = true
AUTO_DELETE_CAMPAIGN_LOG = AutoDeleteCampaignLog.new(auto_delete_campaign)

radio_jar_logfile = File.open("#{Rails.root}/log/radio_jar.log", 'a')
radio_jar_logfile.sync = true
RADIO_JAR = RadioJarLogger.new(radio_jar_logfile)
