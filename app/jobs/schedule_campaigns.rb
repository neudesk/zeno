class ScheduleCampaigns < Struct.new(:param)
  def perform  
    p "******************************************************"
    p "----------------- Schedule Campaigns---------------------"
    p "******************************************************"
    
    days_between_calls = AdminSetting.find_by_name("Days between calls").present? ? AdminSetting.find_by_name("Days between calls").value : 3
    dnc = GoAutoDial.get_dnc_list
    if dnc.present?
      dnc.each do |phone|
        AdminDncList.add_dnc_phone(phone["phone_number"])
      end
    end

    TmpCampaignUploadedListeners.delete_all("date(created_at) < '#{(DateTime.now - 3.day).strftime('%Y-%m-%d')}'")

    past_campaigns = ReachoutTabCampaign.where("date(schedule_start_date) >= '#{(DateTime.now - 45.days).strftime('%Y-%m-%d')}' AND date(schedule_start_date) < '#{DateTime.now.strftime('%Y-%m-%d')}'")
    if past_campaigns.present?
      past_campaigns.each do |campaign|
        ReachoutTabCampaignListener.delete_all(:campaign_id => campaign.id) if campaign.schedule_start_date.strftime('%Y-%m-%d') == (DateTime.now - days_between_calls.to_i.days).strftime('%Y-%m-%d')
        if campaign.id.present?
          SCHEDULE_CAMPAIGN_LOG.debug "Setting campaign with campaign ID: #{campaign.id} to inactive on the dialer."
          response = GoAutoDial.change_campaign_status(false,campaign.id)
          SCHEDULE_CAMPAIGN_LOG.debug "Dialer says: #{response}"
          SCHEDULE_CAMPAIGN_LOG.debug "Deleting audio from campaign ID: #{campaign.id}"
          response = GoAutoDial.delete_audio_files([campaign.id])
          SCHEDULE_CAMPAIGN_LOG.debug "Dialer says: #{response}"
          SCHEDULE_CAMPAIGN_LOG.debug "Updating campaign status from local DB: #{campaign.id} to inactive."
          campaign.update_attribute("status", "Completed")
          SCHEDULE_CAMPAIGN_LOG.debug "Campaign with campaign ID #{campaign.id} is now #{campaign.status}"
        end
      end
    end

    current_day_campaigns = ReachoutTabCampaign.where("date(schedule_start_date) = '#{DateTime.now.strftime('%Y-%m-%d')}'")
    if current_day_campaigns.present?
      current_day_campaigns.each do |campaign|
        if campaign.id.present?
          GoAutoDial.change_campaign_status(true,campaign.id)
          campaign.update_attribute("status", "Active")
        end
      end
    end
    
    p "******************************************************"
    p "-------------- END Schedule Campaigns-----------------"
    p "******************************************************"
  end
end
