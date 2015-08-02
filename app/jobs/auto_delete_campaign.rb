class AutoDeleteCampaign < Struct.new(:param)
  def perform
    AUTO_DELETE_CAMPAIGN_LOG.info "**********************************************"
    AUTO_DELETE_CAMPAIGN_LOG.info "*---------Auto Delete Campaign Job-----------*"
    AUTO_DELETE_CAMPAIGN_LOG.info "**********************************************"

    campaigns = ReachoutTabCampaign.select([:id, :main_id, :schedule_start_date]).where("date(schedule_start_date) > '#{(DateTime.now - 90.days).strftime('%Y-%m-%d')}' AND date(schedule_start_date) < '#{DateTime.now.strftime('%Y-%m-%d')}'").order('schedule_start_date').limit(1)

    AUTO_DELETE_CAMPAIGN_LOG.info "#{campaigns.count} campaigns found!"

    campaigns.each do |camp|
      AUTO_DELETE_CAMPAIGN_LOG.info "Deleting campaign id #{camp.id} that has schedule start date #{camp.schedule_start_date}"
      AUTO_DELETE_CAMPAIGN_LOG.info "running command: GoAutoDial.delete_campaign(#{camp.id})"
      response = GoAutoDial.delete_campaign(camp.id)
      AUTO_DELETE_CAMPAIGN_LOG.debug "Dialer says: #{response}"
    end

    AUTO_DELETE_CAMPAIGN_LOG.info "**********************************************"
    AUTO_DELETE_CAMPAIGN_LOG.info "*--------------------END---------------------*"
    AUTO_DELETE_CAMPAIGN_LOG.info "**********************************************"
  end
end