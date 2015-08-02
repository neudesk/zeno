class SendCampaignsJob < Struct.new(:listeners_type, :reachout_tab_campaign_id, :gateway_id, :schedule_start_date, :name, :call_time, :prompt, :dial_method, :num_channels, :active, :dnc_file)
  LISTENER_LIST_LENGTH = 8000

  def perform
    begin

      CAMPAIGNS_LOG.debug "******************************************************"
      CAMPAIGNS_LOG.debug "START CAMPAIGN FOR '#{DataGateway.find(gateway_id).title}'"
      p "******************************************************"
      p "----------------- Send Campaigns---------------------"
      p "******************************************************"
      # GoAutodial cannot accept phone numbers with country code
      #      # remove country code from phone number if phone number is 11 digit format
      #      # 19173412582 => 9173412582
      #
      # listener_type = {1 => "Active Listeners",
      #                  2 => "Uploaded Listeners",
      #                  3 => "Active + Uploaded Listeners"}

      days_between_calls = AdminSetting.find_by_name("Days between calls").present? ? AdminSetting.find_by_name("Days between calls").value : 3


      grouped_listeners_sql = "SELECT rtlmg.ani_e164,rtlmg.carrier_title,rtmr.entryway_provider FROM
                                `reachout_tab_listener_minutes_by_gateway` as rtlmg
                                LEFT JOIN reachout_tab_mapping_rule as rtmr on rtmr.carrier_title = rtlmg.carrier_title  
                                WHERE  gateway_id = #{gateway_id} AND rtlmg.ani_e164 NOT IN
                                (SELECT phone_number FROM admin_dnc_list) AND rtlmg.ani_e164 NOT IN 
                                (SELECT phone_number FROM reachout_tab_campaign_listener WHERE
                                          DATE(campaign_date)> '#{(DateTime.now - days_between_calls.to_i.days).strftime("%Y-%m-%d")}')
                                          AND rtlmg.ani_e164 != '' AND length(rtlmg.ani_e164) = 11
                                GROUP BY rtlmg.ani_e164,rtlmg.carrier_title"
      grouped_listeners = ActiveRecord::Base.connection.execute(grouped_listeners_sql).to_a

      sql = "
      select
         a.minutes,
        de.did_e164,
        dep.title clec,
        a.carrier_title
      from data_entryway de
              inner join data_entryway_provider dep on de.entryway_provider = dep.id
              left join (
                      select
                              sc.entryway_id,
                              dlac.title carrier_title,
                              sum(sc.seconds / 60) minutes
                      from summary_call sc
                              inner join data_listener_ani_carrier dlac on dlac.id = sc.listener_ani_carrier_id
                      where sc.date >= '#{(DateTime.now - 1.day).strftime("%Y-%m-%d")}'
                              and sc.date < '#{DateTime.now.strftime("%Y-%m-%d")}'
                      group by sc.entryway_id
              ) a on de.id = a.entryway_id
              left join reachout_tab_mapping_rule rtmr on dep.title = rtmr.entryway_provider and a.carrier_title = rtmr.carrier_title
      where de.is_deleted = 0
              and substr(de.did_e164,1,4) not in ('1600','1700')
              and dep.title in
              (
                      select distinct rtmr2.entryway_provider
                      from reachout_tab_mapping_rule rtmr2
              )
              and de.gateway_id = '#{gateway_id}'
      group by de.entryway_provider
      order by a.minutes desc
      "

      top_dids = ActiveRecord::Base.connection.execute(sql).to_a

      primary_clec = AdminSetting.find_by_name('primary_campaign_default_did_provider').value
      secondary_clec = AdminSetting.find_by_name('secondary_campaign_default_did_provider').value

      primary = top_dids.select{|x| x[2].to_s.downcase == primary_clec.to_s.downcase }.first rescue nil
      secondary = top_dids.select{|x| x[2].to_s.downcase == secondary_clec.to_s.downcase }.first rescue nil

      default = primary.present? ? primary : secondary
      third_default = ['', DataEntryway.where("gateway_id = #{gateway_id} and is_deleted = false and substr(did_e164,1,4) not in ('1600','1700')").select(:did_e164).first.did_e164.to_i, 'NO MAPPING', '']
      top_did = top_dids.first.present? ? top_dids.first : third_default
      default_did = default.present? ? default : top_did

      CAMPAIGNS_LOG.debug "Default DID: #{default_did.to_json}"

      if listeners_type == "3"
        list_length = TmpCampaignUploadedListeners.where(:main_campaign_id => reachout_tab_campaign_id).length + grouped_listeners.length
        #update the main campaign
        reachout_tab_campaign = ReachoutTabCampaign.find(reachout_tab_campaign_id)
        reachout_tab_campaign.update_attribute(:listeners_no, list_length)
        CAMPAIGNS_LOG.debug reachout_tab_campaign.to_json
      else
        #update the main campaign
        reachout_tab_campaign = ReachoutTabCampaign.find(reachout_tab_campaign_id)
        reachout_tab_campaign.update_attribute(:listeners_no, grouped_listeners.length)
        CAMPAIGNS_LOG.debug reachout_tab_campaign.to_json
      end

      CAMPAIGNS_LOG.debug "Listener type received is: #{listeners_type}"
      # Active Listeners" or Active + Uploaded Listeners
      if listeners_type == "1" || listeners_type == "3"
        #for each mapping rule is created a individual campaign
        top_dids.each_with_index do |did, index|
          CAMPAIGNS_LOG.debug "Working on DID #{did}"
          listeners = grouped_listeners.select { |l| l[2].to_s.downcase==did[2].to_s.downcase }
          grouped_listeners = grouped_listeners - listeners
          listeners = listeners.map { |x| x[0] }

          # If listeners length is bigger than 6000-7000 DELAYED_JOB is returning an error
          # Net::ReadTimeout
          if listeners.length > LISTENER_LIST_LENGTH
            parts = (listeners.length.to_f / LISTENER_LIST_LENGTH).ceil
            (1..parts).each_with_index do |p, index|
              listener_list = []
              listener_results = []
              index_start = index == 0 ? 0 : (index*LISTENER_LIST_LENGTH)+1
              index_stop = (index+1)*LISTENER_LIST_LENGTH

              # saving campaign to Gui
              reachout_tab_campaign = ReachoutTabCampaign.new
              reachout_tab_campaign.did_e164 = did[1].to_i
              reachout_tab_campaign.gateway_id = gateway_id
              reachout_tab_campaign.generic_prompt = true
              reachout_tab_campaign.schedule_start_date = schedule_start_date
              reachout_tab_campaign.schedule_end_date = schedule_start_date
              reachout_tab_campaign.status = (schedule_start_date.strftime("%Y-%m-%d") == DateTime.now.strftime("%Y-%m-%d")) ? "Active" : "Inactive"
              reachout_tab_campaign.main_id = reachout_tab_campaign_id
              reachout_tab_campaign.did_provider = did[2]
              reachout_tab_campaign.carrier_title = did[3]
              reachout_tab_campaign.save
              CAMPAIGNS_LOG.debug "Code goes here at line 117"
              CAMPAIGNS_LOG.debug reachout_tab_campaign.to_json

              CAMPAIGNS_LOG.debug "SAVING CAMPAIGN = '#{reachout_tab_campaign.id}' - DID provider - #{did[2].to_s}  CARRIER - #{did[3].to_s}  "
              CAMPAIGNS_LOG.debug reachout_tab_campaign.attributes

              listeners[index_start..index_stop].each do |listener|
                listener_list << "(#{gateway_id} ,#{reachout_tab_campaign.id},#{listener.to_s},'#{DateTime.parse(schedule_start_date.to_s).to_s(:db)}', '#{Time.now.to_s(:db)}' )" if listener.chars.first == "1"
                listener_results << listener.to_s.slice(0, 10) if listener.to_s.slice!(0) == "1"
              end

              if listener_results.present?
                listener_results = listener_results.map { |x| x.to_i }
                listener_results = listener_results.uniq
                reachout_tab_campaign.update_attributes(:listeners_no => listener_results.length, :did_provider => did[2])
                # saving campaign to Go_Auto_Dial
                # GoAutodial cannot accept phone numbers with country code
                CAMPAIGNS_LOG.debug "SEND CAMPAIGN TO DIALER - '#{reachout_tab_campaign.id}' - DID provider - #{did[2].to_s}  CARRIER - #{did[3].to_s}  "
                GoAutoDial.add_campaign(reachout_tab_campaign.id, name, call_time, prompt, dial_method, listener_results.join(','), reachout_tab_campaign.did_e164, num_channels, active, dnc_file)
                # saving listeners to reachout_tab_campaign_listener table
                if listener_list.present?
                  sql = "INSERT INTO reachout_tab_campaign_listener(gateway_id,campaign_id, phone_number, campaign_date, created_at) Values #{listener_list.join(',')}"
                  ActiveRecord::Base.connection.execute(sql)
                end
              end
            end
          else
            listener_list = []
            listener_results = []
            if listeners.present?
              # saving campaign to Gui
              reachout_tab_campaign = ReachoutTabCampaign.new
              reachout_tab_campaign.did_e164 = did[1].to_i
              reachout_tab_campaign.gateway_id = gateway_id
              reachout_tab_campaign.generic_prompt = true
              reachout_tab_campaign.schedule_start_date = schedule_start_date
              reachout_tab_campaign.schedule_end_date = schedule_start_date
              reachout_tab_campaign.status = (schedule_start_date.strftime("%Y-%m-%d") == DateTime.now.strftime("%Y-%m-%d")) ? "Active" : "Inactive"
              reachout_tab_campaign.main_id = reachout_tab_campaign_id
              reachout_tab_campaign.did_provider = did[2]
              reachout_tab_campaign.carrier_title = did[3]
              reachout_tab_campaign.save
              CAMPAIGNS_LOG.debug "Code goes here at line 160"
              CAMPAIGNS_LOG.debug reachout_tab_campaign.to_json

              CAMPAIGNS_LOG.debug "SAVING CAMPAIGN = '#{reachout_tab_campaign.id}' - DID provider - #{did[2].to_s}  CARRIER - #{did[3].to_s}  "
              CAMPAIGNS_LOG.debug reachout_tab_campaign.attributes

              listeners.each do |listener|
                listener_list << "(#{gateway_id} ,#{reachout_tab_campaign.id},#{listener.to_s},'#{DateTime.parse(schedule_start_date.to_s).to_s(:db)}', '#{Time.now.to_s(:db)}' )" if listener.chars.first == "1"
                listener_results << listener.to_s.slice(0, 10) if listener.to_s.slice!(0) == "1"
              end

              if listener_results.present?
                listener_results = listener_results.map { |x| x.to_i }
                listener_results = listener_results.uniq
                reachout_tab_campaign.update_attributes(:listeners_no => listener_results.length, :did_provider => did[2])
                # saving campaign to Go_Auto_Dial
                # GoAutodial cannot accept phone numbers with country code

                CAMPAIGNS_LOG.debug "SEND CAMPAIGN TO DIALER - '#{reachout_tab_campaign.id}' - DID provider - #{did[2].to_s}  CARRIER - #{did[3].to_s}  "
                GoAutoDial.add_campaign(reachout_tab_campaign.id, name, call_time, prompt, dial_method, listener_results.join(','), reachout_tab_campaign.did_e164, num_channels, active, dnc_file)
                # saving listeners to reachout_tab_campaign_listener table
                if listener_list.present?
                  sql = "INSERT INTO reachout_tab_campaign_listener(gateway_id,campaign_id, phone_number, campaign_date, created_at) Values #{listener_list.join(',')}"
                  ActiveRecord::Base.connection.execute(sql)
                end
              end
            end
          end
        end

        # Listeners without rule or did_providers
        listeners = grouped_listeners.map { |x| x[0] }
        if listeners_type == "3"
          uploaded_phone = TmpCampaignUploadedListeners.where(:main_campaign_id => reachout_tab_campaign_id).map { |x| x.ani_e164.to_s }
          listeners = uploaded_phone + listeners
        end

        # If listeners length is bigger than 6000-7000 DELAYED_JOB is returning an error
        # Net::ReadTimeout
        if listeners.length > LISTENER_LIST_LENGTH
          # send out campaigns for LISTENER_LIST_LENGTH listeners once
          parts = (listeners.length.to_f / LISTENER_LIST_LENGTH).ceil
          (1..parts).each_with_index do |p, index|
            listener_list = []
            listener_results = []
            index_start = index == 0 ? 0 : (index*LISTENER_LIST_LENGTH)+1
            index_stop = (index+1)*LISTENER_LIST_LENGTH
            did = top_dids[0].present? ? top_dids[0][1].to_i : DataEntryway.where("gateway_id = #{gateway_id} and is_deleted = false and did_e164 NOT LIKE '%1700%' and did_e164 NOT LIKE '%1600%'").select(:did_e164).first.did_e164.to_i
            listeners[index_start..index_stop].each do |listener|
              listener_list << "(#{gateway_id} ,#{reachout_tab_campaign_id},#{listener.to_s},'#{DateTime.parse(schedule_start_date.to_s).to_s(:db)}', '#{Time.now.to_s(:db)}' )" if listener.chars.first == "1"
              listener_results << listener.to_s.slice(0, 10) if listener.to_s.slice!(0) == "1"
            end

            if listener_results.present?
              # saving campaign to Gui
              reachout_tab_campaign = ReachoutTabCampaign.new
              reachout_tab_campaign.did_e164 = default_did[1]
              reachout_tab_campaign.gateway_id = gateway_id
              reachout_tab_campaign.generic_prompt = true
              reachout_tab_campaign.schedule_start_date = schedule_start_date
              reachout_tab_campaign.schedule_end_date = schedule_start_date
              reachout_tab_campaign.status = (schedule_start_date.strftime("%Y-%m-%d") == DateTime.now.strftime("%Y-%m-%d")) ? "Active" : "Inactive"
              reachout_tab_campaign.main_id = reachout_tab_campaign_id
              reachout_tab_campaign.did_provider = default_did[2]
              reachout_tab_campaign.carrier_title = default_did[3]
              reachout_tab_campaign.save
              CAMPAIGNS_LOG.debug "Code goes here at line 223"
              CAMPAIGNS_LOG.debug reachout_tab_campaign.to_json

              CAMPAIGNS_LOG.debug "CREATE CAMPAIGN - '#{reachout_tab_campaign.id}' - DID provider - NO MAPPING  CARRIER - NO CARRIER  "
              CAMPAIGNS_LOG.debug reachout_tab_campaign.attributes

              listener_results = listener_results.map { |x| x.to_i }
              listener_results = listener_results.uniq
              reachout_tab_campaign.update_attribute(:listeners_no, listener_results.length)
              # saving campaign to Go_Auto_Dial
              # GoAutodial cannot accept phone numbers with country code
              CAMPAIGNS_LOG.debug "SEND CAMPAIGN TO DIALER - '#{reachout_tab_campaign.id}' - DID provider - NO MAPPING  CARRIER - NO CARRIER  "
              GoAutoDial.add_campaign(reachout_tab_campaign.id, name, call_time, prompt, dial_method, listener_results.join(','), reachout_tab_campaign.did_e164, num_channels, active, dnc_file)
              if listener_list.present?
                sql = "INSERT INTO reachout_tab_campaign_listener(gateway_id,campaign_id, phone_number, campaign_date, created_at) Values #{listener_list.join(',')}"
                ActiveRecord::Base.connection.execute(sql)
              end

            end
          end
        else
          # IF listener list is smaller than LISTENER_LIST_LENGTH listener
          listener_list = []
          listener_results = []

          did = top_dids[0].present? ? top_dids[0][1].to_i : DataEntryway.where("gateway_id = #{gateway_id} and is_deleted = false and did_e164 NOT LIKE '%1700%' and did_e164 NOT LIKE '%1600%'").select(:did_e164).first.did_e164.to_i
          listeners.each do |listener|
            listener_list << "(#{gateway_id} ,#{reachout_tab_campaign_id},#{listener.to_s},'#{DateTime.parse(schedule_start_date.to_s).to_s(:db)}', '#{Time.now.to_s(:db)}' )" if listener.chars.first == "1"
            listener_results << listener.to_s.slice(0, 10) if listener.to_s.slice!(0) == "1"
          end

          if listener_results.present?
            # saving campaign to Gui
            reachout_tab_campaign = ReachoutTabCampaign.new
            reachout_tab_campaign.did_e164 = default_did[1]
            reachout_tab_campaign.gateway_id = gateway_id
            reachout_tab_campaign.generic_prompt = true
            reachout_tab_campaign.schedule_start_date = schedule_start_date
            reachout_tab_campaign.schedule_end_date = schedule_start_date
            reachout_tab_campaign.status = (schedule_start_date.strftime("%Y-%m-%d") == DateTime.now.strftime("%Y-%m-%d")) ? "Active" : "Inactive"
            reachout_tab_campaign.main_id = reachout_tab_campaign_id
            reachout_tab_campaign.did_provider = default_did[2]
            reachout_tab_campaign.carrier_title = default_did[3]
            reachout_tab_campaign.save
            CAMPAIGNS_LOG.debug "Code goes here at line 267"
            CAMPAIGNS_LOG.debug reachout_tab_campaign.to_json

            CAMPAIGNS_LOG.debug "CREATE CAMPAIGN - '#{reachout_tab_campaign.id}' - DID provider - NO MAPPING  CARRIER - NO CARRIER  "
            CAMPAIGNS_LOG.debug reachout_tab_campaign.attributes


            # If uploaded list + active listeners is selected
            # add the uploaded list to listeners list
            if listeners_type == "3"
              uploaded_phone = TmpCampaignUploadedListeners.where(:main_campaign_id => reachout_tab_campaign_id).map(&:ani_e164)
              uploaded_phone.each do |res|
                listener = res.to_s.strip
                listener_list << "(#{gateway_id} ,#{reachout_tab_campaign.id},#{listener.to_s},'#{DateTime.parse(schedule_start_date.to_s).to_s(:db)}', '#{Time.now.to_s(:db)}' )" if listener.chars.first == "1"
                listener_results << listener.slice(0, 10) if listener.slice!(0) == "1"
              end
            end

            listener_results = listener_results.map { |x| x.to_i }
            listener_results = listener_results.uniq
            reachout_tab_campaign.update_attribute(:listeners_no, listener_results.length)
            # GoAutodial cannot accept phone numbers with country code
            CAMPAIGNS_LOG.debug "SEND CAMPAIGN TO DIALER - '#{reachout_tab_campaign.id}' - DID provider - NO MAPPING  CARRIER - NO CARRIER  "
            GoAutoDial.add_campaign(reachout_tab_campaign.id, name, call_time, prompt, dial_method, listener_results.join(','), reachout_tab_campaign.did_e164, num_channels, active, dnc_file)
            if listener_list.present?
              sql = "INSERT INTO reachout_tab_campaign_listener(gateway_id,campaign_id, phone_number, campaign_date, created_at) Values #{listener_list.join(',')}"
              ActiveRecord::Base.connection.execute(sql)
            end
          end

        end
        # for Uploaded Listeners
      elsif  listeners_type == "2"
        uploaded_phone = TmpCampaignUploadedListeners.where(:main_campaign_id => reachout_tab_campaign_id).map(&:ani_e164)
        parts = (uploaded_phone.length.to_f / LISTENER_LIST_LENGTH).ceil
        did = top_dids[0].present? ? top_dids[0][1].to_i : DataEntryway.where("gateway_id = #{gateway_id} and is_deleted = false and did_e164 NOT LIKE '%1700%' and did_e164 NOT LIKE '%1600%'").select(:did_e164).first.did_e164.to_i
        (1..parts).each_with_index do |p, index|

          index_start = index == 0 ? 0 : (index*LISTENER_LIST_LENGTH)+1
          index_stop = (index+1)*LISTENER_LIST_LENGTH
          listener_results = []
          listener_list = []

          reachout_tab_campaign = ReachoutTabCampaign.new
          reachout_tab_campaign.did_e164 = default_did[1]
          reachout_tab_campaign.gateway_id = gateway_id
          reachout_tab_campaign.generic_prompt = true
          reachout_tab_campaign.schedule_start_date = schedule_start_date
          reachout_tab_campaign.schedule_end_date = schedule_start_date
          reachout_tab_campaign.status = (schedule_start_date.strftime("%Y-%m-%d") == DateTime.now.strftime("%Y-%m-%d")) ? "Active" : "Inactive"
          reachout_tab_campaign.main_id = reachout_tab_campaign_id
          reachout_tab_campaign.did_provider = default_did[2]
          reachout_tab_campaign.carrier_title = default_did[3]
          reachout_tab_campaign.save
          CAMPAIGNS_LOG.debug "Code goes here at line 320"
          CAMPAIGNS_LOG.debug reachout_tab_campaign.to_json

          CAMPAIGNS_LOG.debug "CREATE CAMPAIGN - '#{reachout_tab_campaign.id}' - DID provider - NO MAPPING  CARRIER - NO CARRIER  "
          CAMPAIGNS_LOG.debug reachout_tab_campaign.attributes

          uploaded_phone[index_start..index_stop].each do |res|
            listener = res.to_s.strip
            listener_list << "(#{gateway_id} ,#{reachout_tab_campaign.id},#{listener.to_s},'#{DateTime.parse(schedule_start_date.to_s).to_s(:db)}', '#{Time.now.to_s(:db)}' )" if listener.chars.first == "1"
            listener_results << listener.slice(0, 10) if listener.slice!(0) == "1"
          end

          listener_results = listener_results.map { |x| x.to_i }
          listener_results = listener_results.uniq
          reachout_tab_campaign.update_attribute(:listeners_no, listener_results.length)
          # GoAutodial cannot accept phone numbers with country code

          CAMPAIGNS_LOG.debug "SEND CAMPAIGN TO DIALER - '#{reachout_tab_campaign.id}' - DID provider - NO MAPPING  CARRIER - NO CARRIER  "
          GoAutoDial.add_campaign(reachout_tab_campaign.id, name, call_time, prompt, dial_method, listener_results.join(','), reachout_tab_campaign.did_e164, num_channels, active, dnc_file)

          if listener_list.present?
            sql = "INSERT INTO reachout_tab_campaign_listener(gateway_id,campaign_id, phone_number, campaign_date, created_at) Values #{listener_list.join(',')}"
            ActiveRecord::Base.connection.execute(sql)
          end
        end
      end

      TmpCampaignUploadedListeners.delete_all(:main_campaign_id => reachout_tab_campaign_id)
      ReachoutTabCampaign.find(reachout_tab_campaign_id).update_attribute(:campaign_saved, true)
      CAMPAIGNS_LOG.debug "DELETE TEMPORARY UPLOADED LISTENERS"
      p "******************************************************"
      p "-----------------END Send Campaigns-------------------"
      p "******************************************************"
      CAMPAIGNS_LOG.debug "END CAMPAIGN FOR '#{DataGateway.find(gateway_id).title}'"
      CAMPAIGNS_LOG.debug "******************************************************"
    rescue Exception => e
      CAMPAIGNS_LOG.error "ERROR :  #{e.message}"
      CAMPAIGNS_LOG.error e.backtrace.inspect
      #CampaignsMailer.send_campaign_error(e.backtrace.inspect).deliver
    end
  end
end
