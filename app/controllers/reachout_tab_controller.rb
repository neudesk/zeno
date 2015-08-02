class ReachoutTabController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_user
  require 'csv'
  DEFAULT_CALL_TIME = "default"
  DEFAULT_DAY_BETWEEN_CALLS = "3"
  DIAL_METHOD = "FSA"
  NUMBER_OF_CHANNELS = AdminSetting::default_campaign_num_of_channels

  def index
    @has_no_default = 1
    @total_page = current_user.stations.count.to_f/16
    @total_page = @total_page.ceil
    if current_user.stations.length == 1
      @gateway_id = current_user.stations.first.id
    else
      @gateway_id = params[:gateway_id].present? ? params[:gateway_id] : nil
    end
    @dids = @gateway_id.present? ? DataEntryway.where(:gateway_id =>@gateway_id) : []
    @start = 900
    @stop = 1700
    if @gateway_id.present?

      # check if the gateway has default CLEC
      clecs = AdminSetting.get_default_clec_config.collect{|x| "'#{x.value}'"}
      sql = "SELECT prov.title from data_entryway as de
              left join data_entryway_provider as prov on de.entryway_provider = prov.id
             where de.gateway_id = '#{@gateway_id}' and prov.title in (#{clecs.join(',')}) and substr(de.did_e164,1,4) not in ('1600','1700') and de.is_deleted = 0 group by prov.title"
      result = ActiveRecord::Base.connection.execute(sql).to_a.compact
      @has_no_default = 0 if result.present?

      @listeners_length = get_listeners(@gateway_id).length
      call_time = AdminSetting.find_by_name("Call Time").present? ? AdminSetting.find_by_name("Call Time").value : DEFAULT_CALL_TIME
      call_time_period = GoAutoDial.get_call_time.detect{|c_t| c_t["id"] == call_time }
      @start = call_time_period["ct_default_start"].to_i
      @stop = call_time_period["ct_default_stop"].to_i

      if params[:campaign_id].present?
        campaigns = ReachoutTabCampaign.where(:main_id => params[:campaign_id]).map(&:id)
        not_called_list = GoAutoDial.get_not_called_list(campaigns)
        @ncl_phones = []
        uploaded_listener_list = []
        if not_called_list.present?
          TmpCampaignUploadedListeners.delete_all(:main_campaign_id => params[:campaign_id], :gateway_id => params[:gateway_id])
        end
        if not_called_list["result"].present?
          not_called_list["result"].each do |ncl|
            @ncl_phones << "1" + ncl[0]
            TmpCampaignUploadedListeners.create(ani_e164: ("1"+ncl[0]).to_i, main_campaign_id: params[:campaign_id], gateway_id: params[:gateway_id])
            # uploaded_listener_list << "(#{("1"+ncl[0]).to_i}, #{params[:campaign_id]}, #{params[:gateway_id]},'#{Time.now.to_s(:db)}')"
          end
        end

        # if uploaded_listener_list.present?
        #   TmpCampaignUploadedListeners.delete_all(:main_campaign_id => params[:campaign_id], :gateway_id => params[:gateway_id])
        #   sql = "INSERT INTO tmp_campaign_uploaded_listeners(ani_e164,main_campaign_id,gateway_id,created_at) VALUES #{uploaded_listener_list.join(',')}"
        #   ActiveRecord::Base.connection.execute(sql)
        # end
      end
      @uploaded_listeners = TmpCampaignUploadedListeners.where(:gateway_id => params[:gateway_id], :main_campaign_id => params[:campaign_id]).select(:ani_e164)
    end
  end
  
  # def save
  #   render json: params
  # end

  def save
    # listener_type = {1 => "Active Listeners",
    #                  2 => "Uploaded Listeners",
    #                  3 => "Active + Uploaded Listeners"}
    # Check if user has did's

    if !DataEntryway.where("gateway_id = #{params[:gateway_id]} and is_deleted = false and did_e164 NOT LIKE '%1700%' and did_e164 NOT LIKE '%1600%'").select(:did_e164).first.present?
      @alert = "No DID assigned to the current station."
      # respond_to do |format|
      #   format.js {render "save" and return}
      # end
      redirect_to :back, :alert => "No DID assigned to the current station."
      return
    end

    if !params[:prompt].present?
      @alert = "Please upload a wav file."
      # respond_to do |format|
      #   format.js {render "save" and return}
      # end
       redirect_to :back , :alert => "Please upload a wav file."
       return
    end

    if params[:uploaded_listeners].present?  && params[:active_listeners].present?
      listeners_type = "3"
    elsif params[:uploaded_listeners].present? && !params[:active_listeners].present?
      listeners_type = "2"
    elsif !params[:uploaded_listeners].present? && params[:active_listeners].present?
      listeners_type = "1"
    elsif !params[:uploaded_listeners].present? && !params[:active_listeners].present?
      #@alert = "Please select 'Active Listeners' , 'Uploaded Listeners' or booth ."
      # respond_to do |format|
      #   format.js {render "save" and return }
      # end
      redirect_to :back , :alert => "Please select 'Active Listeners' , 'Uploaded Listeners' or booth ."
      return
    end

    # Campaign schedule section
    call_time = AdminSetting.find_by_name("Call Time").present? ? AdminSetting.find_by_name("Call Time").value : DEFAULT_CALL_TIME
    if params[:schedule] == "send_now"
      call_time_period = GoAutoDial.get_call_time.detect{|c_t| c_t["id"] == call_time }
      time = Time.parse(params[:schedule_hour]).strftime("%H%M").to_i
      start,stop = call_time_period["ct_default_start"].to_i,call_time_period["ct_default_stop"].to_i
      if time > start && time < stop
        schedule_start_date = DateTime.parse(DateTime.now.strftime("%Y-%m-%d #{Time.parse(params[:schedule_hour]).strftime("%H:%M")}"))
        schedule_end_date = schedule_start_date
        call_time = add_call_time(schedule_start_date)
      else
        # @alert = "Campaign cannot be sent.Time interval to can send campaign is #{start}-#{stop}.Please schedule this campaign to another date"
        # respond_to do |format|

        #   format.js {render "save" and return}
        # end
         redirect_to reachout_tab_index_path(:gateway_id =>  params[:gateway_id]), :alert => "Campaign cannot be sent.Time interval to can send campaign is #{start}-#{stop}.Please schedule this campaign to another date"
        return
      end
    else
      if DateTime.parse(params[:schedule_date]) > DateTime.now
        schedule_start_date = DateTime.parse(params[:schedule_date])
        schedule_end_date = DateTime.parse(params[:schedule_date])
        call_time = add_call_time(schedule_start_date)
      else
        # @alert = "Please select a future date."
        # respond_to do |format|
        #   format.js {render "save" and return}
        # end
        redirect_to reachout_tab_index_path(:gateway_id =>  params[:gateway_id]), :alert => "Please select a future date."
        return
      end
    end

    # this is to validate if campaign is already set for a gateway with same sched start date
    camp = ReachoutTabCampaign.select([:id]).where(gateway_id: params[:gateway_id],
                                                   schedule_start_date: schedule_start_date)
    if camp.present?
      redirect_to reachout_tab_index_path(gateway_id: params[:gateway_id]),
      alert: 'Previously created campaign with the same Station and Schedule. Please set this campaign with different time schedule'
      return
    end

    # Listeners type
    if listeners_type == "2" ||  listeners_type == "3"
      if params[:uploaded_phone_list].present?
        uploaded_phone = params[:uploaded_phone_list].split(',').map{|x| x.to_i}
        uploaded_phone = uploaded_phone.uniq
      else
        # @alert = "Uploaded list of phones is empty."
        # respond_to do |format|
        #   format.js {render "save" and return}
        # end
         redirect_to :back, :alert => "Uploaded list of phones is empty."
        return
      end
    elsif get_listeners(params[:gateway_id]).length < 1
      # @alert = "No active listeners for current gateway."
      # respond_to do |format|
      #   format.js {render "save" and return}
      # end
      redirect_to :back, :alert => "No active listeners for current gateway."
      return
    end

    #Saving campaign to GUI DB
    reachout_tab_campaign = ReachoutTabCampaign.new
    reachout_tab_campaign.gateway_id = params[:gateway_id]
    reachout_tab_campaign.generic_prompt = true
    reachout_tab_campaign.prompt = params[:prompt]
    reachout_tab_campaign.schedule_start_date = schedule_start_date
    reachout_tab_campaign.schedule_end_date = schedule_end_date
    reachout_tab_campaign.status = (schedule_start_date.strftime("%Y-%m-%d") == DateTime.now.strftime("%Y-%m-%d")) ? "Active" : "Inactive"
    reachout_tab_campaign.created_by = current_user.id
    reachout_tab_campaign.main_id = 0
    reachout_tab_campaign.created_at = Time.now.in_time_zone('Eastern Time (US & Canada)')
    if reachout_tab_campaign.save

      #for local mode use
      if request.host == "localhost"
        wavfile = "http://107.170.144.247/system/reachout_tab_campaigns/prompts/000/007/637/original/e04a1d0e1d9428cd4308b57c31c21fc6.wav"
      else
        wavfile = "http://#{request.host}" + reachout_tab_campaign.prompt.url(:original, timestamp: false)
      end
      if request.host == "localhost"
        generic_prompt = "http://107.170.144.247/system/reachout_tab_campaigns/prompts/000/007/637/original/e04a1d0e1d9428cd4308b57c31c21fc6.wav"
      else
        if DefaultPrompt.first.present?
          generic_prompt = "http://#{request.host}" + DefaultPrompt.first.prompt.url(:original, timestamp: false)
        else
          generic_prompt = "http://107.170.144.247/system/reachout_tab_campaigns/prompts/000/007/637/original/e04a1d0e1d9428cd4308b57c31c21fc6.wav"
        end
      end

      gateway_name = DataGateway.find(params[:gateway_id]).title
      dial_method = DIAL_METHOD
      name = "#{gateway_name}-#{params[:gateway_id]}"
      num_channels = NUMBER_OF_CHANNELS
      TmpCampaignUploadedListeners.where(:gateway_id => params[:gateway_id]).update_all(:main_campaign_id =>reachout_tab_campaign.id)

      CAMPAIGNS_LOG.info 'Sending campaigns -  Delayed Job is creating a campaign on GO Auto Dial Side'
      Delayed::Job.enqueue ProcessCampaignJob.new(
        listeners_type,
        reachout_tab_campaign.id,
        reachout_tab_campaign.gateway_id,
        schedule_start_date,
        name,
        call_time,
        wavfile,
        dial_method,
        num_channels,
        reachout_tab_campaign.status == "Active" ? "1" : "0",
        generic_prompt
      ), 0
      CAMPAIGNS_LOG.info 'job has been enqued'
      @notice = "Campaign saved."
      @gateway_id = params[:gateway_id]
      @main_id = reachout_tab_campaign.id
      # respond_to do |format|
      #   format.js {render "save" and return}
      # end
      reachout_tab_campaign.create_activity(key: 'reachout_tab_campaign.create',
                                            owner: current_user,
                                            trackable_title: reachout_tab_campaign.id,
                                            user_title: user_title,
                                            parameters: {gateway_id: reachout_tab_campaign.gateway_id,
                                                         start: reachout_tab_campaign.schedule_start_date,
                                                         type: listeners_type,
                                                         id: reachout_tab_campaign.id})
      redirect_to reachout_tab_index_path, :notice => "Campaign saved."
    else
      if reachout_tab_campaign.errors.messages[:prompt].present?
        # @alert = "Campaign not saved. Please upload a valid wav or mp3 file."
        # respond_to do |format|
        #   format.js {render "save" and return}
        # end
         redirect_to reachout_tab_index_path(:gateway_id =>  params[:gateway_id]), :alert => "Campaign not saved. Please upload a valid wav file."
         return
      else
        # @alert =  "Something went wrong."
        # respond_to do |format|
        #   format.js {render "save" and return}
        # end
        redirect_to reachout_tab_index_path(:gateway_id =>  params[:gateway_id]), :alert => "Something went wrong."
      end
    end
  end

  def get_created_campaign_status
    if ReachoutTabCampaign.where(:id => params[:main_id]).select(:campaign_saved).first.campaign_saved
      render :json => "true"
    else
      render :json => "false"
    end
  end

  def upload_listeners
    file_data_result = []
    if params[:upload].present?
      date = Time.now.to_s(:db)
      accepted_formats = [".csv"]
      filename = params[:upload]['datafile'].original_filename
      folder_path = "public/"

      File.open(Rails.root.join("#{folder_path}",filename),'w+b') do |f|
        f.write(params[:upload]['datafile'].read)
      end

      if accepted_formats.include? File.extname(Rails.root.join("#{folder_path}",filename))
        dnc_data = AdminDncList.select('phone_number').map{|dnc| dnc.phone_number.to_i}
        saved_phone_list = TmpCampaignUploadedListeners.where(:gateway_id =>params[:gateway_id]).select(:ani_e164).map{|list| list.ani_e164.to_i}
        file_data = CSV.read(Rails.root.join("#{folder_path}",filename))
        uploaded_listener_list = []
        file_data.each do |data|
          if data[0].to_s.match(/^\d+$/) && (data[0].length == 10 || data[0].length == 11)
            if data[0].length == 10
              file_data_result << ("1" + data[0].to_s).to_i
            else
              file_data_result << data[0].to_i
            end
          end
        end
        file_data_result.length
        #remove dnc phone no
        denied = file_data_result && dnc_data
        @denied = denied.count
        file_data_result = file_data_result - dnc_data
        #remove duplicates
        taken = file_data_result && saved_phone_list
        @taken = taken.count
        file_data_result = file_data_result - saved_phone_list
        file_data_result = file_data_result.uniq

        # saving uploaded listeners to a temp table
        file_data_result.each do |data|
          uploaded_listener_list << "(#{data},#{params[:gateway_id]},'#{date}')"
        end

        if uploaded_listener_list.present?
          sql = "INSERT INTO tmp_campaign_uploaded_listeners(ani_e164,gateway_id,created_at) VALUES #{uploaded_listener_list.join(',')}"
          ActiveRecord::Base.connection.execute(sql)
        end

        @file_data_result_length = TmpCampaignUploadedListeners.where(:gateway_id =>params[:gateway_id]).select(:ani_e164).count
        @file_data_result = file_data_result
        @accepted = file_data_result.count
      end
      File.delete(Rails.root.join("#{folder_path}",filename))
    end
    respond_to do |format|
      format.js {render "upload_listeners"}
    end

  end

  # GoAutoDial Campaign
  def add_call_time(start_call_time)
    call_time = AdminSetting.find_by_name("Call Time").present? ? AdminSetting.find_by_name("Call Time").value : DEFAULT_CALL_TIME
    call_time_period = GoAutoDial.get_call_time.detect{|c_t| c_t["id"] == call_time }
    if call_time_period
      stop = call_time_period["ct_default_stop"].to_i

      r = Random.new
      random_nr = r.rand(1..99999)
      call_time_id = random_nr.to_s + "-" + start_call_time.strftime("%-I%p")
      call_time_name = start_call_time.strftime("%-I%p")
      call_time = start_call_time.strftime("%H%M")
      end_call_time = stop
      all_call_time =  GoAutoDial.get_call_time.detect {|c| c['ct_default_start'] == start_call_time}
      GoAutoDial.add_call_time(call_time_id, call_time_name, call_time, end_call_time) if !all_call_time.present?
      all_call_time.present? ? all_call_time['id'] : call_time_id
    end
  end

  def get_listeners(gateway_id)
    results = []
    days_between_calls = AdminSetting.find_by_name("Days between calls").present? ? AdminSetting.find_by_name("Days between calls").value : DEFAULT_DAY_BETWEEN_CALLS

    sql = "SELECT rtmg.ani_e164 from reachout_tab_listener_minutes_by_gateway as rtmg where rtmg.gateway_id = #{gateway_id} and rtmg.ani_e164 NOT IN
          ( Select phone_number from admin_dnc_list) and rtmg.ani_e164 NOT IN
          (Select phone_number from reachout_tab_campaign_listener where date(campaign_date)> '#{(DateTime.now-days_between_calls.to_i.days).strftime("%Y-%m-%d")}')
                        and rtmg.ani_e164 != '' and length(rtmg.ani_e164) = 11"
    listeners = ActiveRecord::Base.connection.execute(sql).to_a

    # GoAutodial cannot accept phone numbers with country code
    # remove country code from phone number if phone number is 11 digit format
    # 19173412582 => 9173412582
    listeners.each do  |listener|
      results << listener[0].to_s.slice(0,10) if listener[0].to_s.slice!(0) == "1"
    end
    results
  end

  def add_phone
    if params[:ani_e164].present? && params[:gateway_id].present?
      if !TmpCampaignUploadedListeners.where(:ani_e164 => params[:ani_e164], :gateway_id => params[:gateway_id]).present?
        TmpCampaignUploadedListeners.create(:ani_e164 =>params[:ani_e164], :gateway_id => params[:gateway_id])
        phone_list_length = TmpCampaignUploadedListeners.where(:gateway_id => params[:gateway_id]).length
        render :json => {error: 0, message: 'Success', :phone => params[:ani_e164], :phone_list_length =>phone_list_length }
      else
        render :json => {error: 1, message: 'Phone number is already been taken.'}
      end
    else
      render :json => {error: 1, message: 'Insufficient parameters'}
    end
  end

  def search_phone
    if params[:ani_e164].present? && params[:gateway_id].present?
      phones = TmpCampaignUploadedListeners.where("ani_e164 LIKE '#{params[:ani_e164]}%' AND gateway_id = #{params[:gateway_id]}").select(:ani_e164).last(1000).map(&:ani_e164)
      render :json => {:status => "200", :phones =>phones}
    else
      render :json => {:status => "404"}
    end
  end

  def destroy_phone
    if params[:ani_e164].present? && params[:gateway_id].present?
      if TmpCampaignUploadedListeners.where(:ani_e164 =>params[:ani_e164], :gateway_id => params[:gateway_id]).destroy_all
        phone_list_length = TmpCampaignUploadedListeners.where(:gateway_id => params[:gateway_id]).length
        render :json => {:status => "200", :phone => params[:ani_e164], :phone_list_length => phone_list_length}
      end
    else
      render :json => {:status => "404"}
    end
  end

  # def destroy_campaign
  #   if params[:id].present?
  #     campaigns = ReachoutTabCampaign.where(:main_id => params[:id] )
  #     campaigns.each do |c|
  #       GoAutoDial.delete_campaign(c.id)
  #       ReachoutTabCampaign.find(c.id).destroy
  #       ReachoutTabCampaignListener.delete_all(:campaign_id => c.id)
  #     end
  #     GoAutoDial.delete_campaign(params[:id])
  #     ReachoutTabCampaign.find(params[:id]).destroy
  #     ReachoutTabCampaignListener.delete_all(:campaign_id => params[:id])
  #     redirect_to :back , :notice => "Campaing deleted."
  #   else
  #     redirect_to :back , :alert => "Delete campaign failed."
  #   end
  # end

  def campaign_debug
    days_between_calls = AdminSetting.find_by_name("Days between calls").present? ? AdminSetting.find_by_name("Days between calls").value : 3
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
                  and de.gateway_id = '#{params[:gateway_id]}'
          group by de.entryway_provider
          order by a.minutes desc
          "
    clecs = ActiveRecord::Base.connection.execute(sql).to_a
    sql = "SELECT rtlmg.ani_e164,rtlmg.carrier_title,rtmr.entryway_provider FROM
                          `reachout_tab_listener_minutes_by_gateway` as rtlmg
                          LEFT JOIN reachout_tab_mapping_rule as rtmr on rtmr.carrier_title = rtlmg.carrier_title  
                          WHERE  gateway_id = #{params[:gateway_id]} AND rtlmg.ani_e164 NOT IN
                          (SELECT phone_number FROM admin_dnc_list) AND rtlmg.ani_e164 NOT IN 
                          (SELECT phone_number FROM reachout_tab_campaign_listener WHERE
                                    DATE(campaign_date)> '#{(DateTime.now - days_between_calls.to_i.days).strftime("%Y-%m-%d")}')
                                    AND rtlmg.ani_e164 != '' AND length(rtlmg.ani_e164) = 11
                          GROUP BY rtmr.entryway_provider"
    grouped_listeners = ActiveRecord::Base.connection.execute(sql).to_a
    render json: {station_clec: clecs, listener_clecs: grouped_listeners.map{|x| x[2]}}
  end

  def destroy_uploaded_phones
    if params[:id].present?
      TmpCampaignUploadedListeners.delete_all(:gateway_id => params[:id])
    end
    redirect_to reachout_tab_index_path(gateway_id: params[:id])
  end
  protected
  def validate_user
    # TODO Check if Reachout Tab is enabled for current BRD
    if current_user.is_broadcaster?
      is_active = DataGroupBroadcast.joins(:sys_users).where("sys_user.id=?",current_user.id).select("data_group_broadcast.reachout_tab_is_active")
      is_active = is_active[0].present? ? is_active[0].reachout_tab_is_active : false
      redirect_to root_path if !is_active
    elsif current_user.is_rca?
      is_active = DataGroupRca.joins(:sys_users).where("sys_user.id=?",current_user.id).select("data_group_rca.reachout_tab_is_active")
      is_active = is_active[0].present? ? is_active[0].reachout_tab_is_active : false
      redirect_to root_path if !is_active
    end
  end
end
