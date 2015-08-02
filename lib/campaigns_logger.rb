class CampaignsLogger < Logger
   def format_message(severity, timestamp, progname, msg)
  "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
  end
end

class ScheduleCampaignLogger < CampaignsLogger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
  end
end

class AutoDeleteCampaignLog < ScheduleCampaignLogger

end