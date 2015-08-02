class PendingUsersController < ApplicationController
  before_filter :authenticate_user!, except: [:new, :create, :echosign]

  def index
    @users = PendingUser.where("status  IN (?,?,?,?,'')", Status::UNPROCESSED, Status::PENDING_INFO, Status::PENDING_REPLY, Status::PENDING_SERVICES).order("id DESC")
    @q = @users.search(params[:q])
    @users = @q.result(distinct: true).page(params[:page]).per(15)
    @user = PendingUser.new
  end

  def new
    @user = PendingUser.new
    @genre = DataGroupGenre.select([:id, :title]).order('title').map {|x| x.title}
  end

  def create
    @user = PendingUser.new(params[:pending_user])
    @user.streaming_url = params[:streaming_url]
    @user.signup_date = Date.today
    @user.service_type = params[:service_type].join(',') if params[:service_type].present?
    if @user.save
      UserMailer.inform_rt(@user).deliver
      redirect_to echosign_pending_users_path
    else
      render :new
    end
    # render :json => params
  end

  def update_note
    if params[:puser_id].present?
      puser = PendingUser.find(params[:puser_id])
      status = params[:status].present? ? params[:status] : Status::UNPROCESSED
      puser.update_attributes!({:status => status, :note => params[:note]})
      render :json => {'puser_id' => puser.id, :status => puser.status, :note => puser.note}
    end
  end

  def save
  end

  def all
    @users = PendingUser.where("status  IN (?,?,?)", Status::PROCESSED, Status::DUPLICATE, Status::IGNORED).order("date_processed DESC")
    @q = @users.search(params[:q])
    @users = @q.result(distinct: true).page(params[:page]).per(15)
    @user = PendingUser.new
    @new_station = DataGateway.new
  end

  def auto_signups
    if params[:filter].present?
      @users = User.where(:is_auto_signup => true).where('title LIKE ? OR name LIKE ? OR email LIKE ?', params[:filter], params[:filter], params[:filter]).page(params[:page]).per(15)
    else
      @users = User.where(:is_auto_signup => true).page(params[:page]).per(15)
    end
  end

  def signup_settings
    if params[:config].present?
      GlobalSetting.update_config(params[:config][:name], params[:config][:value])
    end
    @providers = DataEntrywayProvider.order('title')
    settings = GlobalSetting.get_signup_configs
    @settings = settings.page(params[:page]).per(15)
    # render :json => @settings
  end

  def ignore
    @user = PendingUser.find_by_id(params[:id])
    if @user.update_attributes(status: Status::IGNORED, note: params[:pending_user][:note], date_processed: Time.now)
      redirect_to :back, notice: "Successfully ignored pending user."
    else
      redirect_to :back, alert: "Error Occured. Please contact system Administrator"
    end
  end

  def all_delete
    PendingUser.find(params[:id]).destroy
    redirect_to :action=>:all
  end

  def destroy_processed_pending_user
    PendingUser.find(params[:id]).destroy
    redirect_to :action=>:all
  end

  def duplicate
    user = PendingUser.find_by_id(params[:id])
    if user.update_attributes(status: Status::DUPLICATE, note: params[:pending_user][:note], date_processed: Time.now)
      redirect_to :back, notice: "Successfully mark user as duplicate."
    else
      redirect_to :back, alert: "Error Occured. Please contact system Administrator"
    end
  end

  def approved
    @user = PendingUser.find_by_id(params[:id])
    @bool, @new_user, @errors = PendingUser.create_from(params[:pending_user])
    if @bool
      @user.update_attributes(status: Status::PROCESSED, date_processed: Time.now, email: params[:pending_user][:email])
      redirect_to user_path(@new_user, new_user: true), notice: "Successfully created new user."
    else
      # @user.errors.add(streaming_url: @new_user.errors['signup_streaming_url'])
      @new_user.errors.messages.each do |key, val|
        key == :title ? @user.errors.add(:name, val.first) : @user.errors.add(key, val.first)
        @user.errors.add(:streaming_url, val.first) if key == :signup_streaming_url
        @user.errors.add(:station_name, val.first) if key == :signup_station_name
      end
      @user.errors.add(:permission_id, "Role can't be blank") if params[:pending_user][:permission_id].empty?
      @user.permission_id = params[:pending_user][:permission_id]
      @user.name = params[:pending_user][:name]
      @user.new_group = params[:pending_user][:new_group]
      @user.group = params[:pending_user][:group]
      render :show
    end
    # render json: params
  end

  def show
    @user = PendingUser.find_by_id(params[:id])
  end

  def echosign
    render layout: 'framed'
  end

end