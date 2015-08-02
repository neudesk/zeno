class PendingUser < ActiveRecord::Base
  self.table_name = :pending_users
  attr_accessible :address, :city, :company_name, :country, :email, :facebook, :genre, :language, :name, :landline, :cellphone, :state, :station_name, :streaming_url, :twitter, :website, :signup_date, :status, :note, :date_processed, :rca, :affiliate, :enabled, :on_air_schedule, :zip_code, :service_type
  attr_accessor :filter, :permission_id, :group, :new_group


  validates :company_name, :country, :service_type, presence: true, on: :create
  validate :uniq_email, on: :create

  def uniq_email
    user = User.find_by_email(email)
    self.errors.add(:email, "Email address already taken") if user.present?
  end

  def unprocessed?
    status == Status::UNPROCESSED
  end

  def duplicate?
    status == Status::DUPLICATE
  end

  def ignored?
    status == Status::IGNORED
  end

  def processed?
    status == Status::PROCESSED
  end

  def pending?
    status == Status::PENDING
  end

  def self.create_from(params)
    user = User.new
    user.permission_id = params[:permission_id]
    user.title = params[:name]
    user.email = params[:email]
    user.password = user.default_password
    user.signup_facebook = params[:facebook]
    user.signup_twitter = params[:twitter]
    user.address = params[:address]
    user.city = params[:city]
    user.state = params[:state]
    user.zip_code = params[:zip_code]
    user.country = params[:country]
    user.landline = params[:landline]
    user.cellphone = params[:cellphone]
    user.signup_rca = params[:rca]
    user.signup_station_name = params[:station_name]
    user.signup_streaming_url = params[:streaming_url]
    user.signup_website = params[:website]
    user.signup_language = params[:language]
    user.signup_genre = params[:genre]
    user.signup_affiliate = params[:affiliate]
    user.name = params[:company_name]
    user.enabled = params[:enabled]
    user.signup_on_air_schedule = params[:on_air_schedule]
    user.service_type = params[:service_type]
    unless user.permission_id == "1"
      unless params[:new_group].present? or params[:group].present?
        user.errors.add(:group, "can't be blank")
        return  false, user, user.errors
      end
    end
    if user.save
      user.new_group = params[:new_group]
      user.group = params[:group]
      if user.new_group.present?
        user.create_new_group(user.new_group)
      else
        user.save_relationships(user.group)
      end
    end
    return user.valid? , user, user.errors
  end

  def self.random_password(length)
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    string = (0...length).map { o[rand(o.length)] }.join
  end
end
