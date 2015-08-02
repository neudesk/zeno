class CampaignResultsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_user
  before_filter :restrict_admin_only , only: [:index]
  require 'csv'

  CAMPAIGN_STATUSES = {0 => "Inactive", 1 => "Active", 2 => "Started", 3 => "Completed"}

  def view
    @campaigns = ReachoutTabCampaign.where(main_id: params[:id])
    campaign_status = []
    @campaigns.each do |c|
      begin
        campaign_status << [GoAutoDial.get_campaign_status(c.id), c.id ]
      rescue
        break
      end
    end
    if campaign_status.present?
      if campaign_status.each.present?
        campaign_status.each do |status|
          if status[0].present?
            status[0].each do |stats|
              if stats[1].present?
                stats[1]['statuses']['total_stats'].each do |values|
                  status_names = GoAutoDialStatuses.find_by_status(values['status'])
                  values['status_name'] = (status_names.present? ? status_names.status_name : '-')
                end
              end
            end
          end
        end
      end
    end
    render json: campaign_status
  end

  def edit
    if params[:id].present? && params[:gateway_id]
      @campaigns = ReachoutTabCampaign.where(main_id: params[:id])
      @mapping_rules = ReachoutTabMappingRule.joins("join reachout_tab_listener_minutes_by_gateway as rtlmg on rtlmg.did_title = entryway_provider").where("rtlmg.gateway_id = #{params[:gateway_id]}").select("reachout_tab_mapping_rule.entryway_provider,reachout_tab_mapping_rule.carrier_title").uniq

      sql = "SELECT dep.title,did_e164 from data_entryway as de 
      INNER join data_entryway_provider as dep on  dep.id  = de.entryway_provider 
      WHERE gateway_id = #{params[:gateway_id]} and is_deleted = false and did_e164 NOT LIKE '%1700%' and did_e164 NOT LIKE '%1600%'"
      @dids = ActiveRecord::Base.connection.execute(sql).to_a
    end
    render layout: false
  end

  def index
    if marketer?
      @campaigns = ReachoutTabCampaign.select("schedule_start_date,id").order('-schedule_start_date').group("date(schedule_start_date)").page(params[:page]).per(10)
    else
      user_stations = current_user.stations.map(&:id)
      @campaigns = ReachoutTabCampaign.select("schedule_start_date,id").where("gateway_id in (#{user_stations.join(',')})").order('-schedule_start_date').group("date(schedule_start_date)").page(params[:page]).per(10)
    end
  end

  def campaigns
    params[:page] ||= 1
    dt = Time.now.in_time_zone('Eastern Time (US & Canada)')
    params[:start] ||= (dt - 30.day).strftime("%Y-%m-%d")
    params[:end] ||= dt.strftime("%Y-%m-%d")
    @gateways = current_user.stations
    creator_sql = "SELECT DISTINCT b.id, b.title from reachout_tab_campaign a inner join sys_user b on a.created_by = b.id WHERE a.created_by IS NOT NULL"
    @creator = ActiveRecord::Base.connection.execute(creator_sql).to_a
    where = "main_id = 0"
    where += " AND schedule_start_date >= '#{params[:start]}' AND schedule_start_date <= '#{(params[:end].to_date + 1.day).strftime("%Y-%m-%d")}' "
    if params[:query].present?
      search_by_gateway = @gateways.select([:id, :title]).where("TRIM(LOWER(title)) LIKE '%#{params[:query].downcase.strip}%'")
      ids = search_by_gateway.present? ? search_by_gateway.collect(&:id).join(',') : '0'
      where += " AND gateway_id in (#{ids}) "
      search_by_creator = User.select([:id, :title]).where("TRIM(LOWER(title)) LIKE '%#{params[:query].downcase.strip}%'")
      ids = search_by_creator.present? ? search_by_creator.collect(&:id).join(',') : '0'
      where += " OR created_by in (#{ids}) "
    else
      where += " AND gateway_id in (#{@gateways.collect(&:id).join(',')}) "
    end
    # if params[:query].present?
    #   search_by_creator = User.select([:id, :title]).where("TRIM(LOWER(title)) LIKE '%#{params[:query].downcase.strip}%'")
    #   where += " OR created_by in ('#{params[:filter_creator]}') " if search_by_creator.present?
    # end
    @campaigns = ReachoutTabCampaign.where(where).order('-schedule_start_date').page(params[:page]).per(16)
    # render json: @campaigns
  end

  def statistics
    stats = nil
    if params[:campaign_id].present?
      camp = ReachoutTabCampaign.find_by_id(params[:campaign_id])
      begin
        stats = camp.statistics
      rescue Exception => e
        GET_CAMPAIGN_STATISTICS_LOG.debug "#{e}"
      end
    end
    render json: stats
  end

  def show
    if marketer?
      @campaign = ReachoutTabCampaign.find_by_id(params[:id])
      date = @campaign.schedule_start_date.strftime("%Y-%m-%d")
      campaign_results = ReachoutTabCampaign.where("date(schedule_start_date) = '#{date}' AND main_id = 0")
    else
      user_stations = current_user.stations.map(&:id)
      @campaign = ReachoutTabCampaign.where("id = #{params[:id]} AND gateway_id in (#{user_stations.join(',')})").first
      date = @campaign.schedule_start_date.strftime("%Y-%m-%d")
      campaign_results = ReachoutTabCampaign.where("date(schedule_start_date) = '#{date}' AND main_id = 0 AND gateway_id in (#{user_stations.join(',')}) ")
    end
    @campaign_results = Kaminari.paginate_array(campaign_results).page(params[:page]).per(5)
  end

  def get_weekly_users
    table_name=""
    where = ""
    if (DateTime.now-1.days).strftime("%m") >= "01" && (DateTime.now-1.days).strftime("%m") < "07"
      table_name = "report_#{(DateTime.now-1.days).strftime('%Y')}_1"
    else
      table_name = "report_#{(DateTime.now-1.days).strftime('%Y')}_2"
    end
    if current_user.is_broadcaster? || current_user.is_rca?
      where = "AND gateway_id IN (#{current_user.stations.pluck(:id).join(',')})"
    end
    date_now = DateTime.now
    date_past = (DateTime.now - 50.minutes)
    weekly_calls = []
    
    if current_user.is_rca? || current_user.is_broadcaster?
      campaigns = current_user.campaigns(date_now.strftime("2014-10-08 00:00:00"), date_past.strftime("2014-10-08 23:59:59"))
      if campaigns.present?
        weekly_calls = GoAutoDial.get_weekly_calls(campaigns)
        weekly_calls = weekly_calls["result"] if weekly_calls["result"].present?
      end
    else
       weekly_calls = GoAutoDial.get_weekly_calls([])
       weekly_calls = weekly_calls["result"] if weekly_calls["result"].present?
    end

    sql = "SELECT WEEK(report_date,6) as week, sum(users_by_time) as users from #{table_name}  WHERE report_date >= CURDATE() - INTERVAL 5 WEEK #{where} GROUP BY week"
    users = ActiveRecord::Base.connection.execute(sql).to_a
    week_data, dialer_calls, dashboard_users = [], [], []

    ((DateTime.now - 6.week).strftime("%U").to_i..DateTime.now.strftime("%U").to_i).each_with_index do |week, index|
      total_users = users.select{|x| x[0] == week}

      if weekly_calls.present? && weekly_calls[week.to_s].present?
        dialer_calls << [week, weekly_calls[week.to_s]["Calls"].to_i]
      else
        dialer_calls << [week, 0]
      end

      if total_users.present?
        dashboard_users << [week, total_users[0][1]]
      else
        dashboard_users << [week, 0]
      end
      index = (index - 6).abs
      start_day = (DateTime.now - index.weeks).at_beginning_of_week(:sunday).strftime("%B (%d ")
      end_day = (DateTime.now - index.weeks).at_end_of_week(:sunday).strftime("- %d)")
      week_data << [week, start_day + end_day]
    end
    render json: [dialer_calls, dashboard_users, week_data]
  end

  def daily_list_status
    if params[:days].present?
      @days = params[:days]
      if @days == "0" 
        date = (DateTime.now - params[:days].to_i).strftime('%Y-%m-%d')
        where = "DATE(reachout_tab_campaign.schedule_start_date) = '#{date}' AND reachout_tab_campaign.main_id = 0"
      else
        invalid_end_date = DateTime.now.strftime('%Y-%m-%d')
        case @days
        when "7"
          start_date = (DateTime.now - 7.days).strftime('%Y-%m-%d')
          end_date = (DateTime.now - 2.days).strftime('%Y-%m-%d')
          invalid_start_date = (DateTime.now - 2.days).strftime('%Y-%m-%d')
        when "15"
          start_date = (DateTime.now - 15.days).strftime('%Y-%m-%d')
          end_date = (DateTime.now - 8.days).strftime('%Y-%m-%d')
          invalid_start_date = (DateTime.now - 7.days).strftime('%Y-%m-%d')
        when "30"
          start_date = (DateTime.now - 30.days).strftime('%Y-%m-%d')
          end_date = (DateTime.now - 16.days).strftime('%Y-%m-%d')
          invalid_start_date = (DateTime.now - 15.days).strftime('%Y-%m-%d')
        when "60"
          start_date = (DateTime.now - 60.days).strftime('%Y-%m-%d')
          end_date = (DateTime.now - 31.days).strftime('%Y-%m-%d')
          invalid_start_date = (DateTime.now - 30.days).strftime('%Y-%m-%d')
        end
        if @days == "60"
         where = "DATE(reachout_tab_campaign.schedule_start_date) <= '#{end_date}' AND NOT reachout_tab_campaign.gateway_id IN 
         (SELECT gateway_id FROM `reachout_tab_campaign` WHERE  DATE(schedule_start_date) > '#{invalid_start_date}' AND DATE(schedule_start_date) <= '#{invalid_end_date}' AND main_id = 0)
         AND main_id = 0"
       else
        where = "DATE(reachout_tab_campaign.schedule_start_date) >= '#{start_date}' AND DATE(reachout_tab_campaign.schedule_start_date) <= '#{end_date}' AND NOT reachout_tab_campaign.gateway_id IN 
        (SELECT gateway_id FROM `reachout_tab_campaign` WHERE  DATE(schedule_start_date) > '#{invalid_start_date}' AND DATE(schedule_start_date) <= '#{invalid_end_date}' AND main_id = 0)
        AND main_id = 0"
      end
      end
      select = "data_gateway.title as title, reachout_tab_campaign.created_by as created_by, reachout_tab_campaign.listeners_no as leads, reachout_tab_campaign.schedule_start_date as last_call"
      @campaigns = ReachoutTabCampaign.joins(:data_gateway).where(where).select(select).order("reachout_tab_campaign.schedule_start_date ASC").page(params[:page]).per(10)
    end
  end

  def get_realtime_calls
    start_time = (DateTime.now - 50.minutes).strftime("%Y-%m-%d %H:%M")
    end_time = DateTime.now.strftime("%Y-%m-%d %H:%M")
    pm, na, pu, campaigns = [], [], [], []
    date_now = DateTime.now
    date_past = (DateTime.now - 50.minutes)

    if current_user.is_rca? || current_user.is_broadcaster?
      campaigns = current_user.campaigns(date_past.strftime("%Y-%m-%d 00:00:00"), date_now.strftime("%Y-%m-%d 23:59:59"))
      if campaigns.present?
        calls_count = GoAutoDial.get_realtime_calls_count(campaigns, start_time, end_time)["result"]
      else
        calls_count = []
      end
    else
      calls_count = GoAutoDial.get_realtime_calls_count(campaigns, start_time, end_time)["result"]
      #calls_count = GoAutoDial.get_realtime_calls_count((DateTime.now - 2880.minutes).to_s(:db), (DateTime.now - 2930.minutes).to_s(:db))["result"]
    end
    (date_past.to_i..date_now.to_i).step(1.minute) do |m|
      time = Time.at(m).strftime('%H:%M')
      min = Time.at(m).strftime('%-M')
      if calls_count.present?
        if calls_count[time].present?
          pm << [min.to_i, calls_count[time]["PM"]]
          pu << [min.to_i, calls_count[time]["PU"]]
          na << [min.to_i, calls_count[time]["NA"]]
        elsif 
          pm << [min.to_i, 0]
          na << [min.to_i, 0]
          pu << [min.to_i, 0]
        end
      elsif 
        pm << [min.to_i, 0]
        na << [min.to_i, 0]
        pu << [min.to_i, 0]
      end
    end
    render json: {"Call Picked Up" => {label: "Call Picked Up", data: pu},
                   "Played Message" => {label: "Played Message", data: pm},
                     "Not Answer" =>{label: "Not Answer", data: na}}
  end

  def get_daily_calls
    start_date = DateTime.now - 7.day
    end_date = DateTime.now 
    pm, na, pu, campaigns = [], [], [], []
    date_now = DateTime.now
    date_past = DateTime.now - 7.day

    if current_user.is_rca? || current_user.is_broadcaster?
      campaigns = current_user.campaigns(start_date.strftime("%Y-%m-%d 00:00:00"), end_date.strftime("%Y-%m-%d 23:59:59"))
      if campaigns.present?
        daily_calls = GoAutoDial.get_daily_calls(campaigns,start_date.to_s(:db), end_date.to_s(:db))["result"]
      else
        daily_calls = []
      end
    else
      daily_calls = GoAutoDial.get_daily_calls(campaigns,start_date.to_s(:db), end_date.to_s(:db))["result"]
    end
    
    (date_past.to_i..date_now.to_i).step(1.day) do |d|
      date = Time.at(d).strftime('%Y-%m-%d')
      format_date = Time.at(d).strftime('%a %d %b')
      if daily_calls.present?
        if daily_calls[date].present?
          pm << [format_date, daily_calls[date]["PM"]]
          pu << [format_date, daily_calls[date]["PU"]]
          na << [format_date, daily_calls[date]["NA"]]
        elsif 
          pm << [format_date, 0]
          na << [format_date, 0]
          pu << [format_date, 0]
        end
      elsif 
        pm << [format_date, 0]
        na << [format_date, 0]
        pu << [format_date, 0]
      end
  end
    render json: {"Call Picked Up" => {label: "Call Picked Up", data: pu},
                   "Played Message" => {label: "Played Message", data: pm},
                    "Not Answer" =>{label: "Not Answer", data: na}}
  end

  def get_campaigns_by_date
    limit = 10
    current_page = params[:page].present? ? params[:page].to_i : 1
    offset = (current_page.to_i * limit) - limit

    campaign_count = ReachoutTabCampaign.select("count(*) as campaigns_count").where("date(schedule_start_date) = '#{ params[:date]}' and main_id = 0" ).first.campaigns_count

    if current_user.is_marketer?
      sql = "SELECT data_gateway.title, reachout_tab_campaign.* FROM `reachout_tab_campaign` 
      INNER JOIN `data_gateway` ON `data_gateway`.`id` = `reachout_tab_campaign`.`gateway_id` 
      WHERE date(reachout_tab_campaign.schedule_start_date) = '#{params[:date]}' and main_id = 0 limit #{offset}, #{limit}"
    else
      user_stations = current_user.stations.map(&:id)
      sql = "SELECT data_gateway.title, reachout_tab_campaign.* FROM `reachout_tab_campaign` 
      INNER JOIN `data_gateway` ON `data_gateway`.`id` = `reachout_tab_campaign`.`gateway_id` 
      WHERE date(reachout_tab_campaign.schedule_start_date) = '#{params[:date]}' and main_id = 0 and reachout_tab_campaign.gateway_id in (#{user_stations.join(',')}) limit #{offset}, #{limit} "
    end
    
    campaigns = ActiveRecord::Base.connection.execute(sql).to_a
    page_no = campaign_count > 10 ? (campaign_count / 10.0).ceil : 1

    render :partial => "campaign_results/campaigns", :locals => {:campaigns => campaigns,
     :date => params[:date],
     :page_no =>page_no,
     :current_page => current_page
   }
 end

 def destroy
  if params[:id].present?
    campaigns = ReachoutTabCampaign.where(:main_id => params[:id]).map(&:id)
    if campaigns.present?
      ReachoutTabCampaignListener.delete_all("campaign_id IN (#{campaigns.join(',')})")
      GoAutoDial.delete_audio_files(campaigns)
      GoAutoDial.delete_campaigns(campaigns)
      ReachoutTabCampaign.delete_all("id IN (#{campaigns.join(',')})")
    end
    reachout_tab_campaign = ReachoutTabCampaign.find(params[:id])
    reachout_tab_campaign.create_activity :key => 'reachout_tab_campaign.destroy',
          :owner => current_user, :trackable_title => reachout_tab_campaign.id,
          :user_title => user_title, :parameters => {campaign: reachout_tab_campaign}
    reachout_tab_campaign.destroy
    ReachoutTabCampaignListener.delete_all(:campaign_id => params[:id])
    redirect_to :back , :notice => "Campaing deleted."
  else
    redirect_to :back , :alert => "Delete campaign failed."
  end
end

def download_phone_lists
  time = Time.now.to_s(:db)
  gateway_id = ReachoutTabCampaign.where(:main_id => params[:id]).first().gateway_id
  gateway_title = DataGateway.find(gateway_id).title
  filename = "#{gateway_title}.csv"
  send_data create_csv(params[:id]), :filename => filename, :type => 'text/csv', :disposition => 'attachment'
end

def create_csv(campaign_id)
  campaigns = ReachoutTabCampaign.where(:main_id => campaign_id).map(&:id)
  phone_numbers = GoAutoDial.get_download_list(campaigns)["value"].map{|x| x.to_i}
  CSV.generate do |csv|
    phone_numbers.each do |phone|
      csv << [phone]
    end
  end
end


def get_campaigns_by_main_id
  if params[:id].present? && params[:gateway_id]
    campaigns = ReachoutTabCampaign.where(:main_id => params[:id])
    mapping_rules = ReachoutTabMappingRule.joins("join reachout_tab_listener_minutes_by_gateway as rtlmg on rtlmg.did_title = entryway_provider").where("rtlmg.gateway_id = #{params[:gateway_id]}").select("reachout_tab_mapping_rule.entryway_provider,reachout_tab_mapping_rule.carrier_title").uniq

    sql = "SELECT dep.title,did_e164 from data_entryway as de 
    INNER join data_entryway_provider as dep on  dep.id  = de.entryway_provider 
    WHERE gateway_id = #{params[:gateway_id]} and is_deleted = false and did_e164 NOT LIKE '%1700%' and did_e164 NOT LIKE '%1600%'"
    dids = ActiveRecord::Base.connection.execute(sql).to_a
  end
  render :partial => "campaign_results/campaigns_edit", :locals => {:campaigns => campaigns, :mapping_rules => mapping_rules, :dids => dids, :gateway_id => params[:gateway_id]}
end

def get_campaign_status
  campaigns = ReachoutTabCampaign.where(:main_id => params[:campaign_id])
  campaign_status = []
  campaigns.each do |c|
    campaign_status << [GoAutoDial.get_campaign_status(c.id), c.id ]
  end
  render :partial => "campaign_status", :locals => {:camapaign_status => campaign_status, :campaign_id => params[:campaign_id]}
end

def get_campaigns_statuses
  campaign_ids = ReachoutTabCampaign.where(:main_id => params[:campaign_id]).map(&:id)
  na, pm, pu, total_all = 0, 0, 0, 0

  campaigns = GoAutoDial.get_campaigns_statuses(campaign_ids)
  if campaigns.present?
    campaign_ids.each do |c|
      total_all += campaigns[c.to_s]["totalAll"].to_i
      if campaigns[c.to_s]["total_stats"].present?
        campaigns[c.to_s]["total_stats"].each do |stats|
          if stats["status"] == "NA" || stats["status"] != "PM" || stats["status"] != "PU"
            na += stats["status_yes"].to_i
          elsif stats["status"] == "PM"
            pm += stats["status_yes"].to_i
          elsif stats["status"] == "PU"
            pu += stats["status_yes"].to_i
          end
        end
      end
    end
    pm_percent = 100 * (pm.to_f / total_all)
    pu_percent = 100 * (pu.to_f / total_all)
    na_percent = 100 * (na.to_f / total_all)
  end
  render :json => {campaign_id: params[:campaign_id], "total_all" => total_all, "pm" => pm, "pu" => pu, "na" => na, "pm_percent" => pm_percent, "pu_percent" => pu_percent, "na_percent" => na_percent}
end

def get_dids_by_provider
  if params[:did_provider].present? && params[:gateway_id]
    sql = "SELECT dep.title,did_e164 from data_entryway as de 
    INNER join data_entryway_provider as dep on  dep.id  = de.entryway_provider 
    WHERE gateway_id = #{params[:gateway_id]} and dep.title LIKE '#{params[:did_provider]}%' and is_deleted = false and did_e164 NOT LIKE '%1700%' and did_e164 NOT LIKE '%1600%'"
    dids = ActiveRecord::Base.connection.execute(sql).to_a
    dids = dids.map {|d| d[1]}
    render :json => dids
  end
end

def update_campaign_did
  if params[:id].present? && params[:did].present? && params[:did_provider].present?
    campaign = ReachoutTabCampaign.find(params[:id])
    did_provider = params[:did_provider] == "NO MAPPING" ? "NO MAPPING" : params[:did_provider]
    if campaign.update_attributes(:did_e164 => params[:did],:did_provider => did_provider)
      GoAutoDial.update_campaign(params[:id], params[:did])
      render :json => "Updated"
    end
  else
    render :json => "Error - Missing params"
  end
end

def update_campaign_status
  if params[:campaign_id].present? && params[:status].present?
    campaign = ReachoutTabCampaign.find(params[:campaign_id])
    if params[:status] == "Completed"
      campaigns = ReachoutTabCampaign.where(:main_id => params[:campaign_id] )
      campaigns.each do |camp|
        GoAutoDial.change_campaign_status(false, camp.id) 
        GoAutoDial.delete_audio_files(camp.id)
      end
    end
    if campaign.update_attribute(:status, params[:status])
      render :json => {:status => "Updated", :campaign_id => params[:campaign_id]}
    end
  else
    render :json => {:status => "Error - Missing params", :campaign_id => params[:campaign_id]}
  end
end

protected
def validate_user
  if current_user.is_rca?
    is_active = DataGroupRca.joins(:sys_users).where("sys_user.id=?",current_user.id).select("data_group_rca.reachout_tab_is_active")
    is_active = is_active[0].present? ? is_active[0].reachout_tab_is_active : false
    redirect_to root_path if !is_active
  elsif current_user.is_broadcaster?
    is_active = DataGroupBroadcast.joins(:sys_users).where("sys_user.id=?",current_user.id).select("data_group_broadcast.reachout_tab_is_active")
    is_active = is_active[0].present? ? is_active[0].reachout_tab_is_active : false
    redirect_to root_path if !is_active
  end
end
end