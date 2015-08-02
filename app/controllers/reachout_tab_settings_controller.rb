class ReachoutTabSettingsController < ApplicationController 
  DEFAULT_CALL_TIME = "default"
  before_filter :authenticate_user!
  before_filter :validate_user
  
  def index
    @mapped_providers = ReachoutTabMappingRule.select([:id, :entryway_provider]).order('entryway_provider').group(:entryway_provider)
    @dnc_list = AdminDncList.last(30)
    @settings = AdminSetting.all 
    @scheduled_default_did = GlobalSetting.get_default_did_configs
    if params[:type] == "rca" || !params[:type].present?
      if params[:search].present?
        rca = DataGroupRca.where("data_group_rca.is_deleted = false and data_group_rca.title LIKE '#{params[:search]}%'").order(:title)        
      else
        rca = DataGroupRca.where(:is_deleted => false).order(:title)
      end
      @rca = rca.page params[:page]
      @page_no = Kaminari.paginate_array([], total_count: rca.length).page(params[:page]).per(25) 
    elsif params[:type] == "brd"
      if params[:search].present?
        broadcasters = DataGroupBroadcast.where("data_group_broadcast.is_deleted = false and data_group_broadcast.title LIKE '#{params[:search]}%'").order(:title)        
      else
        broadcasters = DataGroupBroadcast.where(:is_deleted => false).order(:title)
      end
      @broadcasters = broadcasters.page params[:page]
      @page_no = Kaminari.paginate_array([], total_count: broadcasters.length).page(params[:page]).per(25)
    end

    admin_call_time_value = AdminSetting.find_by_name("Call Time")
    call_times = GoAutoDial.get_call_time.detect{|c| c['id'] == admin_call_time_value.value}
    @val1 = call_times.present? ? call_times['ct_default_start'].to_i/100 : 9
    @val2 = call_times.present? ? call_times['ct_default_stop'].to_i/100 : 17
    @default_prompt = DefaultPrompt.first
  end
  
  def add_default_prompt
    default_prompt = DefaultPrompt.new
    default_prompt.name ="default_prompt"
    if params[:prompt].present?
      default_prompt.prompt = params[:prompt]
      if default_prompt.save
        if DefaultPrompt.all.length == 2
          first_prompt = DefaultPrompt.first
          first_prompt.destroy 
        end
        redirect_to reachout_tab_settings_path, :notice => "Default prompt file uploaded."
      else
        redirect_to reachout_tab_settings_path, :alert => "Please add a wav file."
      end
    else
      redirect_to reachout_tab_settings_path, :alert => "Please add a wav file."
    end
  end

  def add_call_time(start_t,end_t)
    r = Random.new
    random_nr = r.rand(1..99999)
    
    meridian_start = start_t.to_i > 12 ? "PM" : "AM"
    meridian_end = end_t.to_i > 12 ? "PM" : "AM"
    
    start_time_meridian = (start_t.to_i >12 ? start_t.to_i - 12 : start_t.to_i).to_s + meridian_start
    end_time_meridian = (end_t.to_i >12 ? end_t.to_i - 12 : end_t.to_i).to_s + meridian_end
    
    call_time_id = random_nr.to_s + "-" + start_time_meridian
    call_time_name = start_time_meridian + "-" + end_time_meridian
    start_call_time = start_t.to_s + "00"
    end_call_time = end_t.to_s + "00"
    
    #Find call_time if exists in GOAutoDial Call Time DB
    all_call_time =  GoAutoDial.get_call_time.detect {|c| c['ct_default_start'] == start_call_time && c['ct_default_stop'] == end_call_time}
    #If not exists will be added
    GoAutoDial.add_call_time(call_time_id, call_time_name, start_call_time, end_call_time) if !all_call_time.present?
    all_call_time.present? ? all_call_time['id'] : call_time_id
  end
  
  def upload_dnc_file
    if params[:upload].present?
      accepted_formats = [".csv"]
      filename = params[:upload]['datafile'].original_filename
      folder_path = "public/"
    
      File.open(Rails.root.join("#{folder_path}",filename),'w+b') do |f| 
        f.write(params[:upload]['datafile'].read)
      end
    
      if accepted_formats.include? File.extname(Rails.root.join("#{folder_path}",filename))
        dnc_data = AdminDncList.select('phone_number').map(&:phone_number)
        file_data = File.read(Rails.root.join("#{folder_path}",filename)).split("\r\n")
        file_data_result = []
        result = []
        
        file_data.each do |data|
          if data.to_s.match(/^\d+$/) && (data.length == 10 || data.length == 11)
            if data.length == 10
              file_data_result << ("1" + data.to_s)
            else
              file_data_result << data
            end
          end
        end

        file_data_result = file_data_result - dnc_data

        file_data_result.each do |data|
          result << "(" + data.to_s + ",' #{Time.now.to_s(:db)}')"
        end
        
        if result.present?
          sql = "Insert into admin_dnc_list(phone_number, created_at) Values#{result.join(',')}"
          ActiveRecord::Base.connection.execute(sql)
        end
      end
     
      File.delete(Rails.root.join("#{folder_path}",filename))
      redirect_to :back, :notice => "File uploaded"
    else
      redirect_to :back, :alert => "Please add a csv file."
    end
  end
  
  def update_setting
    admin_setting = AdminSetting.find(params[:id])
    parameters = {old_value: admin_setting.value,
                  new_value: params[:value],
                  name: admin_setting.name}
    if admin_setting.name == "Call Time"
      config = GlobalSetting.find_by_group('CALL_TIME')
      call_time = config.value rescue "Start: #{params[:val1]} - End: #{params[:val2]}"
      config.destroy if config.present?
      value = add_call_time(params[:val1], params[:val2])
      if value.present?
        GlobalSetting.create(group: 'CALL_TIME', name: "Call Time", value: "Start: #{params[:val1]} - End: #{params[:val2]}")
      end
      parameters[:old_value] = call_time
      parameters[:new_value] = "Start: #{params[:val1]} - End: #{params[:val2]}"
    else
      value = params[:value]
    end
    if admin_setting.update_attributes(:value => value)
      if parameters[:new_value] != parameters[:old_value]
        admin_setting.create_activity :key => 'admin_setting.update',
                                      :owner => current_user,
                                      :trackable_title => admin_setting.name,
                                      :user_title => user_title,
                                      :parameters => parameters
      end
      render :text => "Succes"
      # render json: parameters
    else
      render :text => "Error"
    end
  end

  def update_default_did
    sched = 1.day.from_now.beginning_of_day
    if GlobalSetting.create_default_did_configs(params, sched)
      render json: {status: 'ok', result: GlobalSetting.get_default_did_configs}
      if Delayed::Job.enqueue(SetDefaultDID.new(params),1, sched)
        CAMPAIGNS_LOG.info "Default CLEC/DID settings has been scheduled to #{sched.strftime('%Y-%m-%d %H:%M')}"
        CAMPAIGNS_LOG.debug "============== End: Scheduling Default CLEC ===================="
      end
    else
      render json: {status: 'error'}
    end
  end
  
  def add_setting
    admin_setting = AdminSetting.new
    admin_setting.name = params[:name]
    admin_setting.value = params[:value]
    if admin_setting.save
      render :text => "Succes"
    else
      render :text => "Error"
    end
  end
  
  def search_phone
    phone_number = params[:phone_number]
    admin_dnc_list = AdminDncList.where("phone_number LIKE '%#{phone_number}%'")
    render :json => {:dnc_list => admin_dnc_list}
  end
  
  def add_phone_dnc
    phone_number = params[:phone_number]
    if !AdminDncList.find_by_phone_number(phone_number).present?
      ani_e164 = DataListenerAni.find_by_ani_e164(phone_number)
      if ani_e164.present?
        admin_dnc_list = AdminDncList.new(:phone_number => phone_number, :listener_id =>ani_e164.listener_id)
        if admin_dnc_list.save 
          render :json => {:message => "Succes",:id=>admin_dnc_list.id }
        else
          render :json => {:message => "Bad format" }
        end
      else
        render :json =>  {:message => "The number is not present in zenoradio database" }
      end
    else
      render :json =>  {:message => "Phone number already exists." }
    end
  end
  
  def delete_phone_dnc
    id = params[:id]
    if AdminDncList.find(id).destroy
      render :json => {:message =>"Succes"}
    else
      render :json => {:message => "Error" }
    end
  end
  
  def activate_broadcaster
    id = params[:id]
    brd = DataGroupBroadcast.find(id)
    status = params[:status]
    if params[:type] == "upload_list"
      success = brd.update_attributes(:upload_list_is_active => status)
    else
      success = brd.update_attributes(:reachout_tab_is_active => status)
      success = brd.update_attributes(:upload_list_is_active => status) if status == "false"
    end
    
    if success
      render :json =>{:message => "Succes",:brd => brd}
    else
      render :json =>{:message => "Error"}
    end
  end
  def activate_rca
    id = params[:id]
    rca = DataGroupRca.find(id)
    status = params[:status]
    if params[:type] == "upload_list"
      success = rca.update_attributes(:upload_list_is_active => status)
      type = "Upload List"
    else
      success = rca.update_attributes(:reachout_tab_is_active => status)
      success = rca.update_attributes(:upload_list_is_active => status) if status == "false"
      type = "Reachout Tab"
    end

    if success
      rca.create_activity :key => 'data_group_rca.update',
                                  :owner => current_user,
                                  :trackable_title => rca.title,
                                  :user_title => user_title,
                                  :parameters => {type: type, status: status}
      render :json =>{:message => "Success",:rca => rca}
    else
      render :json =>{:message => "Error"}
    end
  end
  protected
  def validate_user
    if !current_user.is_marketer? 
      redirect_to root_path
    end
  end
  
end
