class UsersController < ApplicationController
  skip_authorize_resource :only => [:my_account, :edit_account, :update_account]
  before_filter :authenticate_user!, :only => [:my_account, :edit_account, :update_account, :users_account, :show]
  before_filter :restrict_to_admin_rca_only, only: [:users_account]
  PER_PAGE = 10

  layout 'framed', :only => [:signup, :create]

  # GET /users
  # GET /users.json

  def signup
    @user = User.new
    # render :layout => 'framed'
  end

  def create
    @user = User.new(params[:user])
    config = GlobalSetting.find_by_name('default_signup_password')
    @user.password = config.value
    @user.enabled = true
    @user.is_auto_signup = true
    @user.service_type = params[:service_type].join(',')
    @user.title = params[:user][:email]
    if @user.save
      @user.save_countries([params[:user][:country]]) if params[:user][:country].present?
      @user.new_group = params[:user][:name]
      @user.create_new_group(@user.new_group)
      station_data = nil
      note = nil
      begin
        station_data = @user.create_user_station
      rescue Exception => e
        note = "#{e.to_s} <br /> Note: Your account and station is created, however you have no assigned DID yet, Please contact support team and ask to assign DID in your station."
      end
      UserMailer.inform_signup(@user, station_data.present? ? station_data[:entryway] : nil, request.protocol + request.host, note).deliver
      UserMailer.inform_rt(@user).deliver
      redirect_to "https://secure.echosign.com/public/embedesignhtml?rdid=8WD64S34275D28&Editable=true"
    else
      render :signup
    end
    # render :json => params
  end

  def index
    @users = User.order("id").page(params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def show
    params[:page] ||= 1
    @user = User.find_by_id(params[:id])
    gateways = []
    gateways = @user.stations if @user.enabled
    gateways = gateways.present? ? gateways : []
    @gateways = Kaminari.paginate_array(gateways).page(params[:page]).per(16)
  end

  def new
    @user = User.new
  end

  def reset_password
    @user = current_user
  end

  def submit_reset_password
    @user = current_user
    if @user.valid_password?(params[:user][:old_password])
      if params[:user][:password] == params[:user][:password_confirmation]
        if params[:user][:old_password] == params[:user][:password]
          @user.errors.add(:password, "You should change the password")
        elsif @user.update_attributes(password: params[:user][:password])
          sign_in(@user, :bypass => true)
          return redirect_to root_url, notice: "Thank your for resetting your password."
        end
      else
        @user.errors.add(:password, "Password didn't match")
      end
    else
      @user.errors.add(:old_password, "Incorrect old password")
    end
    render :reset_password
  end

  def save
    user_params = params[:user].dup
    group = user_params.delete("group")
    @new_group = user_params.delete("new_group")
    @tags = user_params.delete("tags_holder")
    @countries = user_params.delete("country_holder")
    @user = User.new(user_params)
    @user.password = @user.default_password
    if @user.save
      if @new_group.present?
        @user.create_new_group(@new_group)
      else
        @user.save_relationships(group)
      end
      @user.save_tags(@tags)
      @user.save_countries(@countries)
      redirect_to user_path(@user), notice: "Successfully create new user."
    else
      render "new"
    end
  end

  def switch
    @user = User.find_by_id(params[:id])
    sign_in(:user, @user)
    current_user.create_activity key: 'user.switch', user_title: user_title, owner: current_user, parameters: {to: @user.id}
    redirect_to root_path, notice: "You're now logged in as #{@user.title}."
  end

  def edit_account
    @tags = @current_user.tags_holder || @current_user.tags.collect { |x| x.title }.join(",")
    @countries = @current_user.country_holder || @current_user.countries.collect { |x| x.title }
    @user = current_user
  end

  def edit
    @user = User.find_by_id(params[:id])
    @brd = @user.sys_user_resource_broadcasts.first.data_group_broadcast if @user.sys_user_resource_broadcasts.present?
    @tags = @user.tags_holder || @user.tags.collect { |x| x.title }.join(",")
    @countries = @user.country_holder || @user.countries.collect { |x| x.title }
  end

  def update
    @brd = nil
    @user = User.find_by_id(params[:id])
    user_old_state = @user.dup
    old_group = @user.get_group_title
    user_params = params[:user].dup
    group = user_params.delete(:group)
    @tags = user_params.delete("tags_holder")
    @countries = user_params.delete("country_holder")
    @new_group = user_params.delete("new_group")
    if user_params[:password].blank? || user_params[:password_confirmation].blank?
      user_params.delete(:password)
      user_params.delete(:password_confirmation)
    end
    @user.assign_attributes(user_params)
    changed = @user.changed
    changed_params = []
    if @user.save
      role = params[:user][:permission_id].to_i
      case role
        when 2
          data_group = @user.sys_user_resource_3rdparties
          current_group_name = data_group.first.data_group_3rdparty rescue nil
        when 3
          data_group = @user.sys_user_resource_broadcasts
          current_group_name = data_group.first.data_group_broadcast rescue nil
        when 4
          data_group = @user.sys_user_resource_rcas
          current_group_name = data_group.first.data_group_rca rescue nil
      end
      if params[:user][:edit_group].present? and current_group_name.present? and params[:user][:edit_group] != current_group_name.title
        current_group_name.title = params[:user][:edit_group]
        current_group_name.save()
      end
      if group.present?
        group_changes = @user.save_relationships(group)
      end
      if @new_group.present?
        @user.create_new_group(@new_group)
      end
      @user.save_tags(@tags)
      @user.save_countries(@countries)
      if @user == current_user && user_params[:password].present?
        sign_in(@user, :bypass => true)
      end
      if changed.present?
        changed.each do |value|
          if @user.send(value).present? and @user.send(value) != ''
            changed_params << {field: value,
                               old_state: user_old_state.send(value),
                               new_state: @user.send(value)}
          end
        end
      end
      if changed_params.present?
        @user.create_activity key: 'user.update',
                              user_title: @user.title,
                              owner: current_user,
                              trackable_title: @user.email,
                              parameters: {user_id: @user.id,
                                           changed: changed_params,
                                           old_group: old_group,
                                           new_group: @user.get_group_title,
                                           role: @user.role_name}
      end
      redirect_to user_path(@user), notice: "You have successfully update #{@user.title} details."
    else
      render :edit
    end
    # render json: params
  end

  def update_account
    user_params = params[:user].dup
    @tags = user_params.delete("tags_holder")
    @countries = user_params.delete("country_holder")
    @new_group = user_params.delete("new_group")
    group = user_params.delete("group")
    if params[:user][:password].blank? || params[:user][:password_confirmation].blank?
      user_params.delete(:password)
      user_params.delete(:password_confirmation)
    end
    user_old_state = @current_user.dup
    @current_user.assign_attributes(user_params)
    changed = @current_user.changed
    if @current_user.save
      @current_user.save_tags(@tags)
      @current_user.save_countries(@countries)
      changed_params = []
      if changed.present?
        changed.each do |value|
          changed_params << {field: value,
                             old_state: user_old_state.send(value),
                             new_state: @current_user.send(value)}
        end
      end
      @current_user.create_activity key: 'user.update',
                            user_title: @current_user.title,
                            owner: current_user,
                            trackable_title: @current_user.email,
                            parameters: {user_id: @current_user.id,
                                         changed: changed_params}
      redirect_to my_account_path, notice: "You have successfully update your account."
    else
      render "edit_account"
    end
  end

  def toggle_lock
    @user = User.find(params[:id])

    if @user.access_locked?
      @user.unlock_access!
      @user.create_activity key: 'user.unlock', user_title: user_title, owner: current_user, trackable_title: user_title, parameters: {user: @user.email}
    else
      @user.lock_access!
      @user.create_activity key: 'user.lock', user_title: user_title, owner: current_user, trackable_title: user_title, parameters: {user: @user.email}
    end

    redirect_to users_account_users_path
  end

  def my_account
    @user = current_user
    config = SysConfig.where(:name => 'default_signup_did_provider')
    provider = DataEntrywayProvider.where(:title => config.first.value) if config.present?
    @sel_provider = provider.first.id if provider.present?
  end

  def assign_default_signup_did_provider
    config = {:error => 'Unexpected error has occured!'}
    if params[:provider].present?
      provider = DataEntrywayProvider.find(params[:provider])
      config = SysConfig.where(:name => 'default_signup_did_provider')
      if config.present?
        SysConfig.where(:group => "GLOBAL_SIGNUP_CONFIGS").where(:name => "default_signup_did_provider").update_all(:value => provider.title)
      else
        config = SysConfig.create(:group => 'GLOBAL_SIGNUP_CONFIGS', :name => 'default_signup_did_provider', :value => provider.title)
      end
    end
    render :json => config
  end

  def write_message

    begin
      @admins = []
      Intercom::Admin.all.each { |admin| @admins << [admin.id, admin.name, admin.email] }
      user = Intercom::User.find(:email => params[:user_email])
      id = @admins.select { |a| a[2] == current_user.email }[0][0]

      if params[:message_type] == "email"
        Intercom::Message.create(
            :message_type => params[:message_type],
            :subject => params[:subject],
            :body => params[:message],
            :template => "plain", # or "personal",
            :from => {
                :type => "admin",
                :id => id.to_s
            },
            :to => {
                :type => "user",
                :id => user.id
            })
      else
        Intercom::Message.create(
            :message_type => params[:message_type],
            :body => params[:message],
            :template => "plain", # or "personal",
            :from => {
                :type => "admin",
                :id => id.to_s
            },
            :to => {
                :type => "user",
                :id => user.id
            })
      end
      redirect_to :back, :notice => "Message sent successfully."
    rescue Exception => e
      p e.message
      if e.message == "User Not Found"
        redirect_to :back, :alert => "This Broadcaster is not active or havent logged in to his/her account."
      elsif e.message == "Subject can't be blank"
        redirect_to :back, :alert => "Message not sent.Please enter a subject."
      else
        redirect_to :back, :alert => "Message not sent.Please contact website administrator."
      end
    end
  end

  def reply_to_message
    conversation = Intercom::Conversation.find(:id => params[:message_id])
    conversation.reply(:type => 'admin', :email => '#{current_user.email}', :message_type => 'comment', :body => params[:message], :admin_id => params[:admin_id])
    redirect_to :back
  end

  def get_message_list
    @admins = []
    Intercom::Admin.all.each { |admin| @admins << [admin.id, admin.name, admin.email] }
    @id = @admins.select { |a| a[2] == current_user.email }[0][0]
    @conversations = Intercom::Conversation.find_all(:type => "admin", :id => @id)
    render partial: "message_list"
  end

  def get_conversations
    if params[:message].present?
      @admins = []
      Intercom::Admin.all.each { |admin| @admins << [admin.id, admin.name, admin.email] }
      @id = @admins.select { |a| a[2] == current_user.email }[0][0]
      @conversation = Intercom::Conversation.find(:id => params[:message])
    else
      if @conversations[0].present?
        @message_id = @conversations[0].id
        @conversation = Intercom::Conversation.find(:id => @conversations[0].id)
      else
        @conversation = []
      end
    end
    render partial: "conversations"
  end

  def conversations
    if current_user.present?
      if current_user.is_marketer? || current_user.is_rca?
        @admins = []
        Intercom::Admin.all.each { |admin| @admins << [admin.id, admin.name, admin.email] }
        if  @admins.select { |a| a[2] == current_user.email }[0].present?
          @id = @admins.select { |a| a[2] == current_user.email }[0][0]
        else
          redirect_to :root
          return
        end
        @conversations = Intercom::Conversation.find_all(:type => "admin", :id => @id)
        if @id.present?
          if params[:message].present?
            @conversation = Intercom::Conversation.find(:id => params[:message])
          else
            if @conversations[0].present?
              @message_id = @conversations[0].id
              @conversation = Intercom::Conversation.find(:id => @conversations[0].id)
            else
              @conversation = []
            end
          end
        else
          redirect_to :root
        end
      else
        redirect_to :root
      end
    end
  end


  def info
    user = User.find_by_id(params[:id].to_i)
    user_info = user.extract_info
    user_info[:link] = user_path(user)
    render :json => user_info
  end

  def users_account
    if params[:filter].present?
      filter = params[:filter]
    else
      filter = params[:user].present? ? params[:user][:filter] : "0"
    end

    if current_user.is_marketer?
      if filter == "0"
        @users = User.where(true).order(:title)
      else
        @users = User.where(permission_id: filter).order(:title)
      end
    else
      rca= SysUserResourceRca.find_by_user_id(current_user.id)
      if rca.present?
        @users = User.joins(data_group_broadcasts:[:data_gateways]).where("data_gateway.rca_id = #{rca.rca_id} AND data_gateway.is_deleted = false AND permission_id = 3").order(:last_sign_in_at)
      end
    end

    @q = @users.search(params[:q])
    @users = @q.result(distinct: true).page(params[:page]).per(PER_PAGE)
    @user = User.new
  end

  def users_account1
    if request.get?
      @user = User.new
      @user.data_group_rcas.build
      @user.data_group_3rdparties.build
      @user.data_group_broadcasts.build
      role ||= params[:search][:role] if params[:search]
      key ||= params[:search][:keyword] if params[:search]
      @users = User.filtered_list(role, key).order(:title).page(params[:page]).per(PER_PAGE)
    elsif request.post?
      @user = User.new
      role = params[:user][:role]
      if @user.save_with_assignments(params[:user], (params[:assignments].values rescue nil))
        flash[:success] = 'Successful create!'
        redirect_to :action => :users_account
      else
        @user.data_group_rcas.build
        @user.data_group_3rdparties.build
        @user.data_group_broadcasts.build
        @user.role = role
        @users = User.filtered_list(role, key).order(:title).page(params[:page]).per(PER_PAGE)
      end
    elsif request.put?
      @user = User.find_by_id(params[:id])
      old_permission_id = @user.permission_id
      old_name = @user.title
      old_email = @user.email
      role = params[:user][:role]
      group = params[:user][:group]

      if @user.extract_info[:role] == 2
        old_group = DataGroupRca.find(@user.extract_info[:group]).title
      elsif @user.extract_info[:role] == 4
        old_group = DataGroupBroadcast.find(@user.extract_info[:group]).title
      end

      params[:user].delete(:password) if params[:user][:password].blank?
      if @user.save_with_assignments(params[:user], (params[:assignments].values rescue nil))
        if old_email != @user.email
          current_user.create_activity key: 'user.email_changed', owner: current_user, trackable_title: user_title, parameters: {:old_email => old_email, :new_email => params[:user][:email]}
        end
        if old_name != @user.title
          current_user.create_activity key: 'user.name', owner: current_user, trackable_title: user_title, parameters: {:old_name => old_name, :new_name => params[:user][:title]}
        end
        if old_permission_id != @user.permission_id
          if role== "2"
            new_group = DataGroupRca.find(group).title
          elsif role == "4"
            new_group = DataGroupBroadcast.find(group).title
          end
          current_user.create_activity key: 'user.status_changed', user_title: user_title, owner: current_user, trackable_title: user_title,
                                       parameters: {:user_email => @user.email,
                                                    :user_title => @user.name,
                                                    :old_status => SysUserPermission.find(old_permission_id).title,
                                                    :old_group => old_group,
                                                    :new_status => SysUserPermission.find(@user.permission_id).title,
                                                    :new_group => new_group}
        end
        render :json => {}
      else
        @user.data_group_broadcasts.build
        render :json => {:errors => @user.errors.messages}
      end
    end
  end

  def destroy
    @user = User.find_by_id(params[:id])
    if @user.destroy
      current_user.create_activity key: 'user.user_destroyed', owner: current_user, user_title: user_title, trackable_title: user_title, parameters: {:user_name => @user.name, :user_email => @user.email}
      redirect_to users_account_users_path, notice: "User was successfully deleted."
    else
      flash[:error] = "<ul>" + @user.errors.messages.values.map { |o| o.map { |p| "<li>"+p+"</li>" }.join(" ") }.join(" ") + "</ul>"
      flash[:error] = flash[:error] + "<ul><li>User was unsuccessfully deleted.</li></ul>"
      redirect_to users_account_users_path
    end
  end

  def groups_options
    user = User.find_by_id(params[:user_id])
    if request.xhr?
      role = params[:role].to_i
      case role
        when 2
           data =  DataGroup3rdparty.select([:id, :title]).order('title')
           selected = user.sys_user_resource_3rdparties.first['3rdparty_id'] rescue nil
           current_group_name = DataGroup3rdparty.find_by_id(selected).title rescue nil
        when 3
           data = DataGroupBroadcast.select([:id, :title]).order('title')
           selected = user.sys_user_resource_broadcasts.first.broadcast_id rescue nil
           current_group_name = DataGroupBroadcast.find_by_id(selected).title rescue nil
         when 4
           data = DataGroupRca.select([:id, :title]).order('title')
           selected = user.sys_user_resource_rcas.first.rca_id rescue nil
           current_group_name = DataGroupRca.find_by_id(selected).title rescue nil
       end
    end

    if params[:user_id].nil?
      render :json => {list: self.class.helpers.groups_for_select(data, params[:user_id]), selected: ""}
    else
      case user.role_name
        when "Broadcast user"
          selected = user.sys_user_resource_broadcasts.first.broadcast_id rescue nil
          name = selected.present? ? DataGroupBroadcast.find_by_id(selected).try(:title) : ""
        when "3rd party user"
          selected = user.sys_user_resource_3rdparties.first['3rdparty_id'] rescue nil
          name = selected.present? ? DataGroup3rdparty.find_by_id(selected).try(:title) : ""
        when "RCA user"
          selected = user.sys_user_resource_rcas.first.rca_id rescue nil
          name = selected.present? ? DataGroupRca.find_by_id(selected).try(:title) : ""
      end
      render :json => {list: self.class.helpers.groups_for_select(data, selected), name: name, current_group_name: current_group_name}
    end
  end

  def gateways_checklist
    if request.xhr?
      role = params[:role].to_i
      if role == MyRadioHelper::Role::VALUES['rca'] or role == MyRadioHelper::Role::VALUES['broadcaster']
        data = DataGateway.with_country(params[:country].to_i)
        .list_with_status_on_group(role, params[:group].to_i)
      elsif role == MyRadioHelper::Role::VALUES['3rd_party']
        data = DataEntryway.with_country(params[:country].to_i)
        .list_with_status_on_group(params[:group].to_i)
      end
      # render :text => self.class.helpers.assignments_for_checklist(data)
      render :text => data.to_json
    end
  end

end
