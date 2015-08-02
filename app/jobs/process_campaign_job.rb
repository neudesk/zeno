class ProcessCampaignJob < Struct.new(:listeners_type, :reachout_tab_campaign_id, :gateway_id, :schedule_start_date,
                                      :name, :call_time, :prompt, :dial_method, :num_channels, :active, :dnc_file)

  def perform
    # this variables is for for logging reports only
    @camp = ReachoutTabCampaign.find(reachout_tab_campaign_id)
    @mapped_in_carrier_rule = 0
    @set_to_default_clec = 0
    @rerouted_to_new_clec = 0
    @retain_to_last_used_clec = 0
    @logs = ''
    CAMPAIGNS_LOG.info add_log("Zenoradio SendCampaign Job v2.0")
    CAMPAIGNS_LOG.info add_log("author: Jon")

    begin
      CAMPAIGNS_LOG.info add_log("********************************************************************")
      CAMPAIGNS_LOG.info add_log("* Send Campaigns for gateway #{DataGateway.find(gateway_id).title} *")
      CAMPAIGNS_LOG.info add_log("********************************************************************")
      CAMPAIGNS_LOG.info add_log("Processing #{listeners_type == '2' ? 'UPLOADED' : 'UPLOADED and ACTIVE'} LISTENER")
      process_bucket_listener
      @camp.update_attributes({campaign_saved: true})
    rescue Exception => e
      CAMPAIGNS_LOG.error add_log("ERROR :  #{e.message}")
      CAMPAIGNS_LOG.error add_log(e.backtrace.inspect)
    end
    CAMPAIGNS_LOG.info add_log("DONE")
    CAMPAIGNS_LOG.info add_log("Cleaning up")
    cleanup
    dpaste_link = process_logs
    @camp.update_attributes({dpaste_link: dpaste_link})
  end

  private

  def add_log(string)
    string = "#{string}
    "
    @logs += string
    string
  end

  def process_logs
    options = {body: {content: @logs,
                      syntax: 'shell-session',
                      title: "Logs for campaign ID #{reachout_tab_campaign_id}",
                      poster: 'Dashboard',
                      expiry_days: '7'}
              }
    begin
      response = HTTParty.post('http://dpaste.com/api/v2/', options=options)
      response = response.body
    rescue Exception => e
      response = e
    end
    CAMPAIGNS_LOG.debug response
    response
  end

  def process_bucket_listener
    bucket_listener.each do |bucket|
      listeners = bucket[4].each_slice(6000).to_a
      if listeners.present?
        listeners.each do |listen|
          camp = ReachoutTabCampaign.create(did_e164: bucket[1],
                                            gateway_id: gateway_id,
                                            generic_prompt: true,
                                            schedule_start_date: schedule_start_date,
                                            schedule_end_date: schedule_start_date,
                                            status: (schedule_start_date.strftime("%Y-%m-%d") == DateTime.now.strftime("%Y-%m-%d")) ? "Active" : "Inactive",
                                            main_id: reachout_tab_campaign_id,
                                            did_provider: bucket[2],
                                            carrier_title: bucket[3])
          sql_values = []
          cleaned_phone = []
          listen.each do |res|
            phone = res.to_s.strip
            sql_values << "(#{gateway_id} ,#{camp.id},#{phone.to_s},'#{DateTime.parse(schedule_start_date.to_s).to_s(:db)}', '#{Time.now.to_s(:db)}' )" if phone.chars.first == "1"
            cleaned_phone << phone.slice(0, 10).to_i if phone.slice!(0) == "1"
          end
          cleaned_phone = cleaned_phone.map {|x| x.to_i}.uniq
          camp.update_attribute(:listeners_no, cleaned_phone.length)
          CAMPAIGNS_LOG.info add_log("Im sending-in a campaign to dialer with #{cleaned_phone.length} phone numbers")
          CAMPAIGNS_LOG.info add_log("I'll be using #{bucket[2]} as CLEC and #{bucket[1]} as DID for this campaign")
          result = GoAutoDial.add_campaign(camp.id, name, call_time,
                                           prompt, dial_method, cleaned_phone.join(','),
                                           camp.did_e164, num_channels, active, dnc_file)
          CAMPAIGNS_LOG.info add_log(result)
          if sql_values.present?
            sql = "INSERT INTO reachout_tab_campaign_listener(gateway_id,campaign_id, phone_number, campaign_date, created_at) Values #{sql_values.join(',')}"
            ActiveRecord::Base.connection.execute(sql)
          end
        end
      end
    end
  end

  def bucket_listener
    buckets = get_gateway_dids
    buckets = [get_default_did] if buckets.empty?
    buckets.each do |bucket|
      bucket[4] = []
    end
    #bucket active listeners
    if listeners_type == '1' || listeners_type == '3'
      bad_listener_sql = []
      get_active_listener.each do |phone|
        if phone.present?
          did = buckets.detect{|x| x[2] == phone[3]}
          if did.present?
            did[4] << phone[0]
          else
            did = buckets.detect{|x| x[2] == get_default_did[2]}
            did[4] << phone[0]
            unless is_mapped(get_default_did[2])
              bad_listener_sql << "('#{phone[0]}', '#{phone[2]}', '#{phone[1]}', '#{gateway_id}', '#{get_default_did[2]}', '#{get_default_did[1]}')"
            end
          end
        end
      end
      if bad_listener_sql.present?
        sql = "INSERT INTO bad_listener(ani_e164, clec, carrier, gateway_id, assigned_clec, assigned_did) Values #{bad_listener_sql.join(',')}"
        ActiveRecord::Base.connection.execute(sql)
      end
    end
    #bucket uploaded listener
    uploaded = get_uploaded_listener
    if uploaded.present?
      did = buckets.detect{|x| x[2] == get_default_did[2]}
      did[4] = did[4] + uploaded
      CAMPAIGNS_LOG.info "#{did[4].length} uploaded listeners is set to station CLEC #{did[2]}"
    end
    buckets
  end

  def cleanup
    TmpCampaignUploadedListeners.delete_all(:main_campaign_id => reachout_tab_campaign_id)
  end

  def get_uploaded_listener
    TmpCampaignUploadedListeners.where(:main_campaign_id => reachout_tab_campaign_id).map(&:ani_e164) rescue []
  end

  def get_data_carrier_rules
    sql = "
      select data_parent_carrier.title, dep1.title as old_clec, dep2.title as new_clec from data_carrier_rule
        left join data_parent_carrier on data_parent_carrier.id=data_carrier_rule.parent_carrier_id
        left join data_entryway_provider dep1 on dep1.id=entryway_provider_id
        left join data_entryway_provider dep2 on dep2.id=new_entryway_provider_id
      where gateway_id=#{gateway_id} and is_enabled=1
    "
    ActiveRecord::Base.connection.execute(sql).to_a
  end

  def get_active_listener
    # the mapping to the mapping rule and data_carrier_rule will happen
    # in method is_mapped
    days_between_calls = AdminSetting.find_by_name("Days between calls").present? ? AdminSetting.find_by_name("Days between calls").value : 3
    active_listener_list_sql = "
      SELECT rtlmg.ani_e164, rtlmg.carrier_title, rtlmg.did_title,rtmp.entryway_provider
        FROM reachout_tab_listener_minutes_by_gateway as rtlmg
          left join reachout_tab_mapping_rule rtmp on rtmp.carrier_title=rtlmg.carrier_title and rtmp.entryway_provider=rtlmg.did_title
        WHERE rtlmg.gateway_id = #{gateway_id}
          AND rtlmg.ani_e164 NOT IN (SELECT phone_number FROM admin_dnc_list)
          AND rtlmg.ani_e164 NOT IN (SELECT phone_number FROM reachout_tab_campaign_listener WHERE DATE(campaign_date)> '#{(DateTime.now - days_between_calls.to_i.days).strftime("%Y-%m-%d")}' )
          AND rtlmg.ani_e164 != '' AND length(rtlmg.ani_e164) = 11
      GROUP BY rtlmg.ani_e164, rtlmg.carrier_title
    "
    result = ActiveRecord::Base.connection.execute(active_listener_list_sql).to_a
    carrier_rules = get_data_carrier_rules
    default_clec = get_default_did[2]
    if result.present?
      result.each do |listener|
        if listener[3].nil?
          defaults = [AdminSetting.find_by_name('primary_campaign_default_did_provider').value,
                      AdminSetting.find_by_name('secondary_campaign_default_did_provider').value]
          rule = carrier_rules.select{|x| x[0] == listener[1] and x[1] == listener[2]}
          if rule.present?
            @mapped_in_carrier_rule += 1
            if rule[0][2].present?
              listener[3] = rule[0][2]
              @mapped_in_carrier_rule -= 1
              @rerouted_to_new_clec += 1
            else
              #  if the default CLEC is PRIMARY or Secondary
              #  use it as listeners CLEC
              if defaults.include?(default_clec)
                listener[3] = default_clec
                @mapped_in_carrier_rule -= 1
                @set_to_default_clec += 1
              else
                # else use the CLEC that the listener last called-in on
                # validation of the last called-in on CLEC if exists in current gateway DID CLEC
                # is in place on bucket listener method
                # in case the last called-in on CLEC do not exists on the current gateway DID CLECs
                # it will use the whatever the default CLEC for this gateway
                listener[3] = listener[2]
                @mapped_in_carrier_rule -= 1
                @retain_to_last_used_clec += 1
              end
            end
          else
            #  if the default CLEC is PRIMARY or Secondary
            #  use it as listeners CLEC
            if defaults.include?(default_clec)
              listener[3] = default_clec
              @set_to_default_clec += 1
            else
              # else use the CLEC that the listener last called-in on
              # validation of the last called-in on CLEC if exists in current gateway DID CLEC
              # is in place on bucket listener method
              # in case the last called-in on CLEC do not exists on the current gateway DID CLECs
              # it will use the whatever the default CLEC for this gateway
              listener[3] = listener[2]
              @set_to_default_clec -= 1
              @retain_to_last_used_clec += 1
            end
          end
        end
      end
      CAMPAIGNS_LOG.info add_log("*** Listener Reports ***")
      CAMPAIGNS_LOG.info add_log("Mapped in Reachout Mapping Rules: #{result.select{|x| x[3].present?}.length}")
      CAMPAIGNS_LOG.info add_log("Mapped in Data Carrier Rules: #{@mapped_in_carrier_rule}")
      CAMPAIGNS_LOG.info add_log("Set to Default CLEC: #{@set_to_default_clec}")
      CAMPAIGNS_LOG.info add_log("Set to Reroute CLEC: #{@rerouted_to_new_clec}")
      CAMPAIGNS_LOG.info add_log("Set to Retain on its last called-in on CLEC: #{@retain_to_last_used_clec}")
    end
    result
  end

  def get_default_did
    gateway_dids = get_gateway_dids
    primary_clec = AdminSetting.find_by_name('primary_campaign_default_did_provider').value
    secondary_clec = AdminSetting.find_by_name('secondary_campaign_default_did_provider').value

    primary = gateway_dids.select{|x| x[2].to_s.downcase == primary_clec.to_s.downcase }.first rescue nil
    secondary = gateway_dids.select{|x| x[2].to_s.downcase == secondary_clec.to_s.downcase }.first rescue nil

    default = primary.present? ? primary : secondary
    third_default = ['', DataEntryway.where("gateway_id = #{gateway_id} and is_deleted = false and substr(did_e164,1,4) not in ('1600','1700')").select(:did_e164).first.did_e164.to_i, 'NO MAPPING', '']
    top_did = gateway_dids.present? ? gateway_dids.first : third_default
    default.present? ? default : top_did
  end

  def get_gateway_dids
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

    ActiveRecord::Base.connection.execute(sql).to_a
  end

  def get_mapped_clecs
    ReachoutTabMappingRule.select([:entryway_provider]).group(:entryway_provider).map{|x| x.entryway_provider}
  end

  def is_mapped(clec)
    get_mapped_clecs.include? clec
  end

end