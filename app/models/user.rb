class User < ActiveRecord::Base
  self.table_name = :sys_user
  FROM_DID = 1
  FROM_COUNTRY = 2
  FROM_GATEWAY = 3
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
    :recoverable, :rememberable, :trackable, :validatable, :lockable, :timeoutable

  include PublicActivity::Model

  acts_as_paranoid :column => 'is_deleted', :column_type => 'boolean'
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :name, :password, :password_confirmation, :remember_me,
    :title, :permission_id, :landline, :cellphone, :zip_code, :address, :city, :state, :country,
    :data_group_rcas_attributes, :data_group_3rdparties_attributes,
    :data_group_broadcasts_attributes, :enabled, :signup_facebook, :signup_twitter, :signup_city, :signup_state, :signup_address,
    :signup_station_name, :signup_website, :signup_language, :signup_genre, :signup_rca, :signup_affiliate, :signup_on_air_schedule, :service_type, :signup_streaming_url, :is_auto_signup, :edit_group

  belongs_to :sys_user_permission, foreign_key: :permission_id

  has_many :sys_user_resource_rcas, foreign_key: :user_id
  has_many :data_group_rcas, through: :sys_user_resource_rcas, source: :data_group_rca

  has_many :sys_user_resource_3rdparties, foreign_key: :user_id
  has_many :data_group_3rdparties, through: :sys_user_resource_3rdparties

  has_many :sys_user_resource_broadcasts, foreign_key: :user_id
  has_many :data_group_broadcasts, through: :sys_user_resource_broadcasts
  has_many :aggregate_customs

  has_many :user_tags
  has_many :tags, through: :user_tags, source: :tag
  has_many :user_countries
  has_many :countries, through: :user_countries, source: :country
  has_many :data_gateway_notes, foreign_key: :user_id

  accepts_nested_attributes_for :data_group_rcas, :data_group_3rdparties, :data_group_broadcasts

  validates_associated :data_group_rcas, :data_group_3rdparties, :data_group_broadcasts
  validates_presence_of :password_confirmation, :if => Proc.new { |a| a.password.present? && a.password_confirmation.present?}
  validates_presence_of :email
  validates :email, uniqueness: true
  validates :sys_user_permission, presence: true
  validates :password, presence: true, on: :create
  validate :uniq_streaming_url, on: :create
  validate :uniq_group_name, on: :create
  validate :presence_of_country, on: :create

  attr_accessor :role, :group, :new_group, :should_save_accessors, :country, :filter, :tags_holder, :country_holder, :edit_group

  after_initialize :should_save_accessors_on
  before_validation :should_save_accessors_off
  after_save :should_save_accessors_on
  scope :rcas, self.joins('left join sys_user_resource_rca on sys_user_resource_rca.user_id=sys_user.id').where('sys_user_resource_rca.id is not null')
  scope :broadcasters, self.joins('left join sys_user_resource_br=oadcast on sys_user_resource_broadcast.user_id=sys_user.id').where('sys_user_resource_broadcast.id is not null')
  scope :_3rdparties, self.joins('left join sys_user_resource_3rdparty on sys_user_resource_3rdparty.user_id=sys_user.id').where('sys_user_resource_3rdparty.id is not null')
  scope :marketers, self.joins('
    left join sys_user_resource_broadcast on sys_user_resource_broadcast.user_id=sys_user.id
    left join sys_user_resource_3rdparty on sys_user_resource_3rdparty.user_id=sys_user.id
    left join sys_user_resource_rca on sys_user_resource_rca.user_id=sys_user.id').where('sys_user_resource_rca.id is null AND sys_user_resource_3rdparty.id is null AND sys_user_resource_broadcast.id is null')

  def presence_of_country
    self.errors.add(:country, 'Please select country') if country.nil?
  end

  def uniq_group_name
    case role_name
      when "Broadcast user"
        new_group = DataGroupBroadcast.where(title: name)
      when "3rd party user"
        new_group = DataGroup3rdparty.where(title: name)
      when "RCA user"
        new_group = DataGroupRca.where(title: name)
    end
    self.errors.add(:name, "Company name is already exists.") if new_group.present?
  end

  def uniq_streaming_url
    if signup_streaming_url.present?
      content = DataContent.where(:media_url => signup_streaming_url)
      self.errors.add(:signup_streaming_url, "Streaming URL is already exists.") if content.present?
    end
  end

  def default_password
    x = case role_name
    when "Super user"
      "zenoradio368"
    when "Broadcast user"
      "zenoradio0704"
    when "3rd party user"
      "zenoradio1225"
    when "RCA user"
      "zenoradio0214"
    end
    return x
  end

  def create_user_station
    data_country = DataGroupCountry.where(:title => country) if country.present?
    data_gateway = DataGateway.create(:title => signup_station_name)
    data_gateway.update_attributes(country_id: data_country.first.id) if data_country.present?
    brd = self.sys_user_resource_broadcasts.first if self.sys_user_resource_broadcasts.present?
    self.search_and_assign_gateway(brd.broadcast_id)
    data_gateway.update_attributes(broadcast_id: brd.broadcast_id)
    if signup_streaming_url.present?
      content = DataContent.create(:title => signup_station_name, :media_url => signup_streaming_url)
      DataGatewayConference.public_activity_off
      conference = DataGatewayConference.create(:gateway_id => data_gateway.id,
                                                :content_id => content.id,
                                                :extension => 1)
    end
    config = GlobalSetting.find_by_name('default_signup_did_provider')
    provider = DataEntrywayProvider.where(:title => config.value).first
    entryway = provider.data_entryways.where(:gateway_id => nil).first
    raise "CLEC provider #{provider.title} has no available DID." if entryway.nil?
    entryway.update_attributes(gateway_id: data_gateway.id) if entryway.present?
    return {:gateway => data_gateway, :entryway => entryway}
  end

  def search_and_assign_gateway(brd_id)
    gateway = DataGateway.where(:broadcast_id => brd_id)
    if gateway.present?
      gateway.each do |gw|
        gw.update_attributes(:broadcast_id => nil)
      end
    end
  end

  def update_broadcast_group_name(name)
    if sys_user_resource_broadcasts.present?
      brd = sys_user_resource_broadcasts.first.data_group_broadcast
      brd.update_attributes(title: name)
    end
  end

  def create_new_group(new_group)
    case role_name
    when "Broadcast user"
      new_group = DataGroupBroadcast.create(title: new_group)
    when "3rd party user"
      new_group = DataGroup3rdparty.create(title: new_group)
    when "RCA user"
      new_group = DataGroupRca.create(title: new_group)
    end
    self.save_relationships(new_group.id)
  end

  def get_group_title
    case role_name
      when "Broadcast user"
        if sys_user_resource_broadcasts.present?
          tmp = sys_user_resource_broadcasts.first
          DataGroupBroadcast.find(tmp.broadcast_id).title rescue nil
        end
      when "3rd party user"
        if sys_user_resource_3rdparties.present?
          tmp = sys_user_resource_3rdparties.first
          DataGroup3rdparty.find(tmp.send("3rdparty_id")).title rescue nil
        end
      when "RCA user"
        if sys_user_resource_rcas.present?
          tmp = sys_user_resource_rcas.first
          DataGroupRca.find(tmp.rca_id).title rescue nil
        end
    end
  end

  def save_relationships(group)
    tmp = nil
    changed = false
    case role_name
    when "Broadcast user"
      if sys_user_resource_broadcasts.present?
        tmp = sys_user_resource_broadcasts.first
      else
        tmp = sys_user_resource_broadcasts.new
      end
      tmp.broadcast_id = group
    when "3rd party user"
      if sys_user_resource_3rdparties.present?
        tmp = sys_user_resource_3rdparties.first
      else
        tmp = sys_user_resource_3rdparties.new
      end
      tmp["3rdparty_id"] = group
    when "RCA user"
      if sys_user_resource_rcas.present?
        tmp = sys_user_resource_rcas.first
      else
        tmp = sys_user_resource_rcas.new
      end
      tmp.rca_id = group
    end
    changed = tmp.changed
    tmp.save if tmp.present?
    return changed
  end

  def save_tags(value)
    self.user_tags.delete_all
    return true unless value.present?
    tags = value.split(",")
    tags.each do |tag|
      tag_object = Tag.find_by_title(tag) || Tag.create(title: tag)
      self.user_tags.create(tag_id: tag_object.id)
    end
  end

  def save_countries(values)
    self.user_countries.delete_all
    return true unless values.present?
    values.each do |country_title|
      country = DataGroupCountry.find_by_title(country_title)
      self.user_countries.create(country_id: country.id) if country.present?
    end
  end

  def station_countries
    ids = stations.collect(&:country_id) << 0
    return DataGroupCountry.where(:id => ids)
  end

  def campaigns(start_date, end_date)
    campigns = ReachoutTabCampaign.where("schedule_start_date >= '#{start_date}' AND schedule_start_date <= '#{end_date}' and main_id = 0 AND gateway_id IN (#{self.stations.pluck(:id).join(",")})").pluck(:id)
  end

  def role_name
    sys_user_permission.try(:title)
  end

  def is_marketer?
    self.enabled && (self.sys_user_permission.is_super_user || self.sys_user_permission.can_manage_all_zenoradio_data)
  end

  def is_thirdparty?
    self.enabled && self.sys_user_permission.can_manage_specific_3rdparty_resources && !sys_user_resource_3rdparties.blank?
  end

  def is_rca?
    self.enabled && self.sys_user_permission.can_manage_specific_rca_resources && !sys_user_resource_rcas.blank?
  end

  def is_broadcaster?
    self.enabled && self.sys_user_permission.can_manage_specific_broadcast_resources && !sys_user_resource_broadcasts.blank?
  end
  
  def is_intercom_admin?
    begin
      admins = []
      Intercom::Admin.all.each {|admin| admins << [admin.id, admin.name, admin.email]}
      admins.select{|a| a[2] == self.email}[0].present? ? true : false
    rescue Exception => e
      false
    end
  end

  def permission_level
    if is_marketer?
      "Admin"
    elsif is_rca?
      "Rca"
    elsif is_broadcaster?
      "Broadcaster"
    elsif is_thirdparty?
      "Third party"
    end
  end

  def get_user_title
    user = User.find_by_id(self.id)
    if is_rca?
      if user.present?
        user.data_group_rcas ? user.data_group_rcas.first.title : ""
      else
        ""
      end
    elsif is_broadcaster?
      if user.present?
       user.data_group_broadcasts.present? ? user.data_group_broadcasts.first.title : ""
      else
        ""
      end
    elsif is_thirdparty?
      if user.present?
        user.data_group_3rdparties.present? ? user.data_group_3rdparties.first.title : ""
      else
        ""
      end
    end
  end
  
  def station_data
    if is_broadcaster?
      data_gateway = DataGateway.get_for_rca_broadcast(self)
      unless data_gateway.nil?
        station_name = data_gateway.first.present? ? data_gateway.first.title : ""
        station_did = data_gateway.first.present? && data_gateway.first.data_entryways.present? ? data_gateway.first.data_entryways.first.did_e164 : ""
      end
    else
      station_name = ""
      station_did = ""
    end
    [station_name, station_did]
  end

  def language
    if is_broadcaster?
      language = DataGateway.get_for_rca_broadcast(self).map(&:language_id).first
      language = language.present? ? DataGroupLanguage.find(language).title : ""
    else
      language = ""
    end
  end

  # def station_name
  #   if is_broadcaster?
  #     station_name = DataGateway.get_for_rca_broadcast(self).map(&:title).first
  #     station_name = station_name.present? ? station_name : ""
  #   else
  #     station_name = ""
  #   end
  # end
  
  def get_rca_for_current_brd
    if is_broadcaster?
      sql = "SELECT dg_rca.title FROM data_gateway as dg INNER JOIN data_group_rca as dg_rca on dg_rca.id = dg.rca_id
             WHERE dg.broadcast_id = #{self.sys_user_resource_broadcasts.first.broadcast_id} limit 1 "
      rca_name = ActiveRecord::Base.connection.execute(sql).to_a
      rca_name = rca_name[0].present? && rca_name[0][0].present? ? rca_name[0][0] : "null"
    else
      "null"
    end
  end

  PROFILE_COMPLETENESS = [
    :email, 
    :name,
    :signup_station_name, 
    :signup_streaming_url, 
    :service_type, 
    :landline, 
    :signup_website, 
    :cellphone, 
    :address, 
    :city, 
    :state, 
    :country, 
    :zip_code, 
    :signup_facebook, 
    :signup_twitter
  ] 

  def profile_percent 
    p = PROFILE_COMPLETENESS.count{ |a| self[a].present? }
    (((p.to_f / PROFILE_COMPLETENESS.count) * 100).to_i).to_s
  end

  def get_stations_dids_options(gateway_id = nil)
    if self.is_thirdparty?
      arrs = DataEntryway.with_3rdparty(self).order(:title) if gateway_id.nil?
      arrs = DataEntryway.where("gateway_id = #{gateway_id}").order(:title) if gateway_id
    elsif self.is_marketer?
      arrs = DataGateway.order(:title) if gateway_id.nil?
      arrs = DataGateway.where("id = #{gateway_id}").order(:title) if gateway_id
    else
      arrs = DataGateway.get_for_rca_broadcast(self).order(:title) if gateway_id.nil?
      arrs = DataGateway.where("id = #{gateway_id}").order(:title) if gateway_id
    end
    results = (arrs.length < 2) ? {} : {"All" => "0"}
    arrs.each do |x|
      results.merge!({x.title => x.id})
    end
    results
  end
  
  def get_options(gateway_id, entryway_id = nil)
    if self.is_thirdparty?
      if entryway_id.nil?
        relations = DataEntryway.with_3rdparty(self).order(:title) if gateway_id.nil?
        relations = DataEntryway.where("gateway_id =  #{gateway_id}").order(:title) if gateway_id
        return [relations.map(&:id), relations.map(&:title)]
      else
        return [[entryway_id], DataEntryway.find_all_by_id(entryway_id).map(&:title)]
      end
    else
      if gateway_id
        return [[gateway_id], DataGateway.find_all_by_id(gateway_id).map(&:title)]
      else
        if self.is_marketer?
          relations = DataGateway.order(:title)
          return [relations.map(&:id), relations.map(&:title)]
        else
          relations = DataGateway.get_for_rca_broadcast(self).order(:title)
          return [relations.map(&:id), relations.map(&:title)]
        end
      end
    end
  end

  def extract_info
    result = self.serializable_hash(:only => [:title, :email, :enabled])
    if self.is_marketer?
      result[:role] = MyRadioHelper::Role::VALUES['marketer']
    elsif self.is_rca?
      result[:role] = MyRadioHelper::Role::VALUES['rca']
      result[:group] = self.sys_user_resource_rcas.first.rca_id
    elsif self.is_broadcaster?
      result[:role] = MyRadioHelper::Role::VALUES['broadcaster']
      result[:group] = self.sys_user_resource_broadcasts.first.broadcast_id
    else
      result[:role] = MyRadioHelper::Role::VALUES['3rd_party']
      result[:group] = self.sys_user_resource_3rdparties.first['3rdparty_id'] rescue nil
    end    
    result
  end

  def self.filtered_list(role=nil, keyword='')
    if role.blank?
      data = self
    elsif role.to_i == MyRadioHelper::Role::VALUES['marketer']
      data = self.marketers
    elsif role.to_i == MyRadioHelper::Role::VALUES['rca']
      data = self.rcas
    elsif role.to_i == MyRadioHelper::Role::VALUES['3rd_party']
      data = self._3rdparties
    elsif role.to_i == MyRadioHelper::Role::VALUES['broadcaster']
      data = self.broadcasters
    end
    data.where(['title LIKE :keyword or email LIKE :keyword', {:keyword => "%#{keyword}%"}])
    .select('sys_user.id, sys_user.title, sys_user.email, sys_user.landline, sys_user.cellphone')
    .group('sys_user.id')
  end

  def set_permission(role)
    if role.to_i==MyRadioHelper::Role::VALUES['marketer']
      self.sys_user_permission = SysUserPermission.find_by_is_super_user(true)
    elsif role.to_i==MyRadioHelper::Role::VALUES['rca']
      self.sys_user_permission = SysUserPermission.find_by_can_manage_specific_rca_resources(true)
    elsif role.to_i==MyRadioHelper::Role::VALUES['3rd_party']
      self.sys_user_permission = SysUserPermission.find_by_can_manage_specific_3rdparty_resources(true)
    elsif role.to_i==MyRadioHelper::Role::VALUES['broadcaster']
      self.sys_user_permission = SysUserPermission.find_by_can_manage_specific_broadcast_resources(true)
    end

  end

  def save_with_assignments(user_attrs, assignments=nil)

    group = user_attrs.delete :group
    role = user_attrs.delete :role
    self.attributes = user_attrs
    if role.blank?
      self.valid?
      self.errors.add(:role, 'Role cannot be blank')
      return false
    elsif role.to_i==MyRadioHelper::Role::VALUES['marketer']
      self.set_permission(role)
      self.title = self.sys_user_permission.title if (self.new_record? && self.title.empty?)
      self.save
    else
      if group.blank? and user_attrs[:data_group_rcas_attributes].blank? and user_attrs[:data_group_3rdparties_attributes].blank? and user_attrs[:data_group_broadcasts_attributes].blank?
        self.valid?
        self.errors.add(:group, 'Group cannot be blank')
        return false
      else
        if role.to_i==MyRadioHelper::Role::VALUES['rca']
          if self.sys_user_resource_rcas.present?
            self.sys_user_resource_rcas.first.update_attributes(:rca_id => group)
          else
            self.sys_user_resource_rcas.build(:rca_id => group) if group.present? and !self.sys_user_resource_rcas.exists?(:rca_id => group)
          end
        elsif role.to_i==MyRadioHelper::Role::VALUES['3rd_party']
          if self.sys_user_resource_3rdparties.present?
            self.sys_user_resource_3rdparties.first.update_attributes('3rdparty_id' => group)
          else
            self.sys_user_resource_3rdparties.build('3rdparty_id' => group) if group.present? and !self.sys_user_resource_3rdparties.exists?('3rdparty_id' => group)
          end
        elsif role.to_i==MyRadioHelper::Role::VALUES['broadcaster']
          if self.sys_user_resource_broadcasts.present?
            self.sys_user_resource_broadcasts.first.update_attributes(:broadcast_id => group)
          else
            self.sys_user_resource_broadcasts.build(:broadcast_id => group) if group.present? and !self.sys_user_resource_broadcasts.exists?(:broadcast_id => group)
          end
        end

        if assignments.present?
          assgined_groups = assignments
          if role.to_i==MyRadioHelper::Role::VALUES['rca']
            if group.present?
              self.sys_user_resource_rcas.first.data_group_rca.data_gateways.delete_all
              self.sys_user_resource_rcas.first.data_group_rca.data_gateways << DataGateway.where(:id => assgined_groups)
            else
              self.data_group_rcas.first.data_gateways.delete_all
              self.data_group_rcas.first.data_gateways << DataGateway.where(:id => assgined_groups)
            end
          elsif role.to_i==MyRadioHelper::Role::VALUES['broadcaster']
            if group.present?
              self.sys_user_resource_broadcasts.first.data_group_broadcast.data_gateways.delete_all
              self.sys_user_resource_broadcasts.first.data_group_broadcast.data_gateways << DataGateway.where(:id => assgined_groups)
            else
              self.data_group_broadcasts.first.data_gateways.delete_all
              self.data_group_broadcasts.first.data_gateways << DataGateway.where(:id => assgined_groups)
            end
          elsif role.to_i==MyRadioHelper::Role::VALUES['3rd_party']
            if group.present?
              self.sys_user_resource_3rdparties.first.data_group_3rdparty.data_entryways.delete_all
              self.sys_user_resource_3rdparties.first.data_group_3rdparty.data_entryways << DataEntryway.where(:id => assgined_groups)
            else
              self.data_group_3rdparties.first.data_entryways.delete_all
              self.data_group_3rdparties.first.data_entryways << DataEntryway.where(:id => assgined_groups)
            end
          end
        end
        
        self.set_permission(role)
        self.title = self.sys_user_permission.title if (self.new_record? && self.title.empty?)
        self.save
      end
    end
  end

  # For slides
  def stations
    if is_thirdparty?
      DataGateway.with_thirdparty(self).order("TRIM(data_gateway.title) ASC").uniq
    elsif is_rca? || is_broadcaster?
      DataGateway.get_for_rca_broadcast(self).order("TRIM(data_gateway.title) ASC")
    elsif is_marketer?
      DataGateway.order("TRIM(data_gateway.title) ASC")
    end
  end

  # For number listeners of home page
  def listener_entryways(order = nil)
    select_str = "data_gateway.title as station_name,
                  data_content.title as channel,
                  count(*) as listeners,
                  now_session.listen_extension as extension"
    if is_thirdparty? || is_marketer?
      select_str += " ,now_session.call_did_e164 as did"
      DataEntryway.get_for_3rd_marketer(self).joins([:now_sessions => [:data_listener, :data_content, :data_gateway]])
      .group("now_session.listen_content_id, now_session.call_gateway_id, now_session.listen_extension, now_session.call_did_e164")
      .select(select_str)
      .order("listeners DESC, data_content.title")

    elsif is_rca? || is_broadcaster?
      # call_did_e164 listen_extension listen_content_id
      if order.present?
        DataGateway.get_for_rca_broadcast(self).joins([:now_sessions => [:data_listener, :data_content, :data_gateway]])
        .group("now_session.listen_content_id, now_session.call_gateway_id, now_session.listen_extension")
        .select(select_str)
        .order("station_name #{order}")
      else
        DataGateway.get_for_rca_broadcast(self).joins([:now_sessions => [:data_listener, :data_content, :data_gateway]])
        .group("now_session.listen_content_id, now_session.call_gateway_id, now_session.listen_extension")
        .select(select_str)
        .order("listeners DESC, data_content.title")
      end
    end
  end

  # For map of home page
  def listeners
    if is_rca? || is_broadcaster?
      DataGateway.get_for_rca_broadcast(self).joins([:data_group_country, :now_sessions => :data_listener])
      .where("data_group_country.iso_alpha_2 = ?", "US")
      .where("data_listener.area_code is not ?", nil)
      .group("data_listener.id")
      .select("data_listener.area_code")


    elsif is_thirdparty? || is_marketer?
      DataEntryway.get_for_3rd_marketer(self).joins([:data_group_country, :now_sessions => :data_listener])
      .where("data_group_country.iso_alpha_2 = ?", "US")
      .where("data_listener.area_code is not ?", nil)
      .group("data_listener.id")
      .select("data_listener.area_code")
    end
  end

  def amount_of_prompts
    created_prompt = PublicActivity::Activity.where("`key`='data_gateway.create_prompt' and user_title LIKE '%#{self.email}%' ").select('count(*) as sum').first.sum
    deleted_prompt = PublicActivity::Activity.where("`key`='data_gateway.destroy_prompt' and user_title LIKE '%#{self.email}%' ").select('count(*) as sum').first.sum
    created_prompt - deleted_prompt
  end
  
  def total_minutes
    total_minutes = 0
    if is_rca? || is_broadcaster?
      minutes = DataListenerAtGateway.get_total_minutes(self, nil)
      total_minutes = minutes > 0 ? minutes : 0
    end
    total_minutes
  end
  
  def get_intercom_minutes(type)
    if is_rca? || is_broadcaster?
      ids = DataGateway.get_for_rca_broadcast(self).map(&:id)
      if ids.present?
        case type
        when "this_month_minutes"
          sql = "SELECT SUM(total_minutes) FROM report_summary_listen WHERE content_id IS NULL AND gateway_id IN (#{ids.join(",")}) 
                              AND report_date >= '#{(Date.today.at_beginning_of_month).strftime("%Y-%m-%d")}' 
                              AND report_date <= '#{(Date.today.at_end_of_month).strftime("%Y-%m-%d")}'"
          this_month_minutes = ActiveRecord::Base.connection.execute(sql).to_a
          this_month_minutes = this_month_minutes.present? && this_month_minutes[0].present? ? this_month_minutes[0][0] : 0
        when "today_minutes"
          sql = "SELECT sum(total_minutes) from report_total_minutes_by_day where gateway_id IN (#{ids.join(',')}) and report_date = '#{DateTime.now.strftime("%Y-%m-%d")}'"
          today_minutes = ActiveRecord::Base.connection.execute(sql).to_a
          today_minutes = today_minutes.present? && today_minutes[0].present? ? today_minutes[0][0] : 0
        when "yestarday_minutes"
          sql = "SELECT SUM(total_minutes) FROM report_summary_listen WHERE content_id IS NULL AND gateway_id IN (#{ids.join(",")}) 
                       AND report_date = '#{(DateTime.now - 1).strftime("%Y-%m-%d")}'"
          yestarday_minutes = ActiveRecord::Base.connection.execute(sql).to_a
          yestarday_minutes = yestarday_minutes.present? && yestarday_minutes[0].present? ? yestarday_minutes[0][0] : 0
        when "last_7_days_minutes"
          sql = "SELECT SUM(total_minutes) FROM report_summary_listen WHERE content_id IS NULL AND gateway_id IN (#{ids.join(",")}) 
                       AND report_date >= '#{(DateTime.now - 7.days).strftime("%Y-%m-%d")}'AND report_date < '#{DateTime.now.strftime("%Y-%m-%d")}'"
          last_7_days_minutes = ActiveRecord::Base.connection.execute(sql).to_a
          last_7_days_minutes = last_7_days_minutes.present? && last_7_days_minutes[0].present? ? last_7_days_minutes[0][0] : 0
        when "last_30_days_minutes"
          sql = "SELECT SUM(total_minutes) FROM report_summary_listen WHERE content_id IS NULL AND gateway_id IN (#{ids.join(",")}) 
                       AND report_date >= '#{(DateTime.now - 30.days).strftime("%Y-%m-%d")}'AND report_date < '#{DateTime.now.strftime("%Y-%m-%d")}'"
          last_30_days_minutes = ActiveRecord::Base.connection.execute(sql).to_a
          last_30_days_minutes = last_30_days_minutes.present? && last_30_days_minutes[0].present? ? last_30_days_minutes[0][0] : 0
        when "all_minutes"
          sql = "SELECT SUM(total_minutes) FROM report_summary_listen WHERE content_id IS NULL AND gateway_id IN (#{ids.join(",")})"
          all_minutes = ActiveRecord::Base.connection.execute(sql).to_a
          all_minutes = all_minutes.present? && all_minutes[0].present? ? all_minutes[0][0] : 0
        end
      else
        return 0
      end
    else
      return 0
    end
  end
  
  
  # For numerical reports
  # For top_stations
  def self.top_stations(user ,options = {})
    where_cl = ["date(summary_listen.date) >= '#{options[:day].to_i.send("days").ago}'"]
    where_cl << "dg.rca_id IN (#{user.data_group_rca_ids.join(",")})" if user.is_rca?
    sql = "SELECT data_group_country.title as country_name,
           sum(summary_listen.seconds) as minutes,
           dg.title as gateway_name,
           dg.id as gateway_id,
           data_group_rca.title as rca_title,
           data_group_broadcast.title as broadcaster_title,
           (0) as new_users,
           (0) as return_users
            FROM data_gateway as dg
            INNER JOIN summary_listen ON summary_listen.gateway_id = dg.id
            INNER JOIN data_group_country ON data_group_country.id = dg.country_id
            INNER JOIN data_group_rca ON data_group_rca.id = dg.rca_id
            INNER JOIN data_group_broadcast ON data_group_broadcast.id = dg.broadcast_id
            WHERE #{where_cl.join(" AND ")}
            GROUP BY dg.title
            ORDER BY sum(summary_listen.seconds) DESC"
    self.find_by_sql(sql)
  end

  # For numerical reports
  # For top_listeners
  def top_listeners(options = {})
    where_str = []
    sort = "minutes desc"
    unless options[:week].blank?
      start_date = Date.commercial(DateTime.now.year, options[:week].to_i).beginning_of_week
      end_date = Date.commercial(DateTime.now.year, options[:week].to_i).end_of_week
      where_str = ["log_call.date_start BETWEEN '#{start_date}' AND '#{end_date}'"]
    end
    sort = "#{options[:sort]} #{options[:direction]}" unless options[:sort].blank?
    where_str << "data_gateway.id = '#{options[:gateway_id]}'" unless options[:gateway_id].blank?
    assinged_gateways = self.is_rca? ? DataGateway.with_rca(self) : DataGateway
    assinged_gateways.joins("INNER JOIN log_call ON log_call.gateway_id = data_gateway.id
                             LEFT JOIN data_listener_ani ON log_call.listener_id = data_listener_ani.listener_id
                             LEFT JOIN data_listener ON data_listener.id = log_call.listener_id
                             LEFT JOIN data_listener_ani_carrier ON data_listener_ani_carrier.id = data_listener_ani.carrier_id")
    .group("data_gateway.id, log_call.listener_id")
    .where(where_str.join(" AND "))
    .select("data_gateway.title as gateway_name,
                              data_listener.title as listener,
                              date(log_call.date_start) as date,
                              sum(log_call.seconds) as minutes,
                              GROUP_CONCAT( DISTINCT data_listener_ani.ani_e164) as anis,
                              GROUP_CONCAT( DISTINCT data_listener_ani_carrier.title) as carriers,
                              count(*) as listener_count")
    .order(sort)
  end

  # For numerical reports
  # For day_broken_by_stream
  def day_broken_by_stream(options = {})
    where_str = []
    sort = "date desc"
    unless options[:week].blank?
      start_date = Date.commercial(DateTime.now.year, options[:week].to_i).beginning_of_week
      end_date = Date.commercial(DateTime.now.year, options[:week].to_i).end_of_week
      where_str = ["log_call.date_start BETWEEN '#{start_date}' AND '#{end_date}'"]
    end
    sort = "#{options[:sort]} #{options[:direction]}" unless options[:sort].blank?
    where_str << "data_gateway.id = '#{options[:gateway_id]}'" unless options[:gateway_id].blank?
    where_str << "log_listen.content_id = '#{options[:content_id]}'" unless options[:content_id].blank?
    assinged_gateways = self.is_rca? ? DataGateway.with_rca(self) : DataGateway
    assinged_gateways.joins("INNER JOIN log_call ON log_call.gateway_id = data_gateway.id
                             INNER JOIN log_listen ON log_call.id = log_listen.log_call_id
                             LEFT JOIN data_content ON data_content.id = log_listen.content_id
                             LEFT JOIN data_listener_ani ON log_call.listener_id = data_listener_ani.listener_id
                             LEFT JOIN data_listener ON data_listener.id = log_call.listener_id
                             LEFT JOIN data_listener_ani_carrier ON data_listener_ani_carrier.id = data_listener_ani.carrier_id")
    .group("data_gateway.id, log_call.listener_id, log_listen.content_id")
    .where(where_str.join(" AND "))
    .select("data_gateway.title as gateway_name,
                              data_listener.title as listener,
                              data_content.title as stream,
                              date(log_call.date_start) as date,
                              sum(log_listen.seconds) as minutes,
                              GROUP_CONCAT( DISTINCT data_listener_ani.ani_e164) as anis,
                              GROUP_CONCAT( DISTINCT data_listener_ani_carrier.title) as carriers,
                              count(*) as listener_count")
    .order(sort)
  end

  def anis_days_not_active(options = {})
    wheres = []
    havings = []
    if options[:category_type] == User::FROM_DID && !options[:did].blank?
      wheres << "log_call.entryway_id = '#{options[:did]}'"
    elsif options[:category_type] == User::FROM_COUNTRY && !options[:country_id].blank?
      wheres << "data_entryway.country_id = #{options[:country_id]}"
    elsif options[:category_type] == User::FROM_GATEWAY && !options[:country_id].blank?
      wheres << "log_call.gateway_id = #{options[:gateway_id]}"
    end

    havings << "minutes = #{options[:callminutes].to_i*60}" unless options[:callminutes].blank?

    havings << "date(date) <= '#{options[:nocalldays].to_i.days.ago.to_date}'" unless options[:nocalldays].blank?

    havings << "date(date) >= '#{options[:calldays].to_i.days.ago.to_date}'" unless options[:calldays].blank?

    assinged_gateways = self.is_rca? ? DataGateway.with_rca(self) : DataGateway
    assinged_gateways.joins("INNER JOIN log_call ON log_call.gateway_id = data_gateway.id
                             INNER JOIN data_entryway ON data_entryway.id = log_call.entryway_id
                             LEFT JOIN data_listener_ani ON log_call.listener_ani_id = data_listener_ani.id
                             LEFT JOIN data_listener_ani_carrier ON data_listener_ani_carrier.id = data_listener_ani.carrier_id")
    .where(wheres.join(" AND "))
    .group("log_call.did_e164")
    .having(havings.join(" AND "))
    .select("log_call.did_e164 as did,
                              log_call.ani_e164 as ani,
                              data_listener_ani_carrier.title as carrier,
                              sum(log_call.seconds) as minutes,
                              log_call.date_start as date")
  end

  def export_anis_days_not_active(current_ability, options = {})
    column_names = %W(ani did provider minutes)
    data = anis_days_not_active(options)
    CSV.generate do |csv|
      csv << %W(ANI DID Carrier Minutes)
      data.each do |row|
        csv << row.attributes.values_at(*column_names)
      end
    end
  end


  # for report marketer, custom chart
  #dids
  def get_entryways_report
    entryways = []
    removal_country_childs = self.aggregate_customs.only_countries.get_gateway_ids.uniq
    removal_gateway_childs = self.aggregate_customs.only_gateways.where("aggregate_custom.removable_id IN (?)", removal_country_childs.map(&:gateway_id)).get_entryway_ids.uniq
    if removal_gateway_childs.exists?
      entryways = SummaryListen.joins(:data_entryway)
      .group("summary_listen.entryway_id, data_entryway.did_e164, data_entryway.country_id")
      .select("data_entryway.country_id, sum(seconds) as total_second, summary_listen.entryway_id as obj_id, data_entryway.did_e164 as obj_name, #{SummaryListen::ENTRYWAY} as obj_type")
      entryways = entryways.where("summary_listen.entryway_id IN (?)", removal_gateway_childs.map(&:entryway_id))

      removal_entryways = self.aggregate_customs.only_entryways

      entryways = entryways.where("summary_listen.entryway_id NOT IN (?)", removal_entryways.map(&:removable_id)) if removal_entryways.size > 0
    end
    entryways
  end

  def get_gateways_report
    gateways = []
    removal_country_childs = self.aggregate_customs.only_countries.get_gateway_ids.uniq
    if removal_country_childs.exists?
      gateways = SummaryListen.joins(:data_gateway)
      .group("summary_listen.gateway_id, data_gateway.title, data_gateway.country_id")
      .select("data_gateway.country_id, sum(seconds) as total_second, summary_listen.gateway_id as obj_id, data_gateway.title as obj_name, #{SummaryListen::GATEWAY} as obj_type")
      gateways = gateways.where("summary_listen.gateway_id IN (?)", removal_country_childs.map(&:gateway_id))
      removal_gateways = self.aggregate_customs.only_gateways
      gateways = gateways.where("summary_listen.gateway_id NOT IN (?)", removal_gateways.map(&:removable_id)) if removal_gateways.size > 0
    end
    gateways
  end

  def get_countries_report
    countries = SummaryListen.get_countries_report
    .select("data_gateway.country_id as obj_id, data_group_country.title as obj_name, #{SummaryListen::COUNTRY} as obj_type")

    removal_countries = self.aggregate_customs.only_countries
    if removal_countries.exists?
      countries = countries.where("data_gateway.country_id NOT IN (?)", removal_countries.map(&:removable_id))
    end
    countries
  end

  def get_objects_custom_aggregate_report
    result = self.get_countries_report
    gateways = self.get_gateways_report
    contents = self.get_entryways_report
    result = "(#{result.to_sql}) UNION (#{gateways.to_sql})" if gateways.present?
    result = "#{(result.is_a?(String) ? result : result.to_sql)} UNION (#{contents.to_sql})" if contents.present?
    result = (result.is_a?(String) ? result : result.to_sql)
    result = [result, ' ORDER BY country_id ASC, obj_type ASC, obj_name ASC'].join
    SummaryListen.find_by_sql(result)
  end

  def get_aggregate_custom_chart(options = {broken_down_by: :day}, from_date=1.week.ago.to_date)

    result = SummaryListen.get_aggregate_default(options, from_date)

    list_countries = self.aggregate_customs.only_countries.with_remove_children
    if list_countries.exists?
      result = result.where("data_group_country.id NOT IN (?)",
        list_countries.map(&:removable_id))
    end

    countries_without_removed_childs = self.aggregate_customs.only_countries.without_remove_children
    list_gateways = self.aggregate_customs.only_gateways.with_remove_children
    removed_list_gateways = nil
    if countries_without_removed_childs.exists? && list_gateways.exists?
      removed_list_gateways = DataGateway.where(id: list_gateways.map(&:removable_id),
        country_id: countries_without_removed_childs.map(&:removable_id))
      if removed_list_gateways.exists?
        result = result.where("gateway_id NOT IN (?)",
          removed_list_gateways.map(&:id))
      end
    end

    list_entryways = self.aggregate_customs.only_entryways
    if removed_list_gateways.present? && list_entryways.exists?
      removed_list_entryways = DataEntryway.where(id: list_entryways.map(&:removable_id),
        gateway_id: removed_list_gateways.map(&:id))
      if removed_list_entryways.exists?
        removed_entry_way_aggregates = SummaryListen.get_aggregate(options, from_date).where("entryway_id IN (?)", list_entryways.map(&:id))
        result.each do |r|
          removed_entry_way_list = removed_entry_way_aggregates.select { |re| re.called_date == r.called_date}

          if removed_entry_way_list.size > 0
            r.total_minutes = r.total_minutes.to_f - removed_entry_way_list[0].total_minutes.to_f
          end

        end
      end
    end
    result
  end

  def get_phone_listeners
    return [] unless self.stations.present?
    NowSession.where("call_ani_e164 <> '' and call_ani_e164 IS NOT NULL")
    .where(call_gateway_id: self.stations.pluck(:id))
    .where('length(call_ani_e164)=11')
    .pluck(:call_ani_e164)
    .compact
  end

  def get_widget_listeners
    return [] unless self.stations.present?
    NowSession.where(call_type: 'WIDGET')
    .where(call_gateway_id: self.stations.pluck(:id))
    .pluck(:call_widget_listener_ip)
  end

  def get_app_listeners
    return [] unless self.stations.present?
    NowSession.where("substr(call_did_e164,1,4)='1600'")
    .where(call_gateway_id: self.stations.pluck(:id))
    .pluck(:call_ani_e164)
  end

  #track uncheck_list/check_list for aggregate_customs
  # note that if any items existed in the table,
  # it means that items were removed out aggregate custom chart
  def track_aggregate_customs(check_list, broken_down, from_day)
    if check_list[:status] != AggregateCustom::REMOVE
      # track for items that's removed from aggregate custom chart
      track_removal_item(check_list[:country_ids], DataGroupCountry, broken_down, from_day)
      track_removal_item(check_list[:gateway_ids], DataGateway, broken_down, from_day)
      track_removal_item(check_list[:content_ids], DataEntryway, broken_down, from_day)
    else # remove for items that's added to aggregate custom chart
      gateway_ids = check_list[:gateway_ids].map{|x| x.split("_").first}
      content_ids = check_list[:content_ids].map{|x| x.split("_").first}
      remove_removal_item(check_list[:country_ids], gateway_ids, DataGroupCountry) if (!gateway_ids.present? || gateway_ids.first.blank?)
      remove_removal_item(check_list[:gateway_ids], content_ids, DataGateway) if (!content_ids.present? || content_ids.first.blank?)
      remove_removal_item(check_list[:content_ids], nil, DataEntryway)
    end
  end

  protected
  # list with format: ["3_true"], first item => id, last_item => remove_children
  # klass: for polymorphic
  def track_removal_item(list, klass, broken_down, from_day)
    list.each do |id|
      remove_children = id.split('_').last
      i = id.split('_').first
      self.aggregate_customs.create(removable_id: i, removable_type: klass.to_s, remove_children: remove_children)
      if(remove_children == "true" && (klass == DataGroupCountry || klass == DataGateway))
        track_children(i, DataGateway, broken_down, from_day) if klass == DataGroupCountry
        track_children(i, DataEntryway, broken_down, from_day) if klass == DataGateway
      end
    end if list.present?
  end

  def track_children(id, c_klass, broken_down, from_day)
    if(c_klass == DataGateway)
      ids = SummaryListen.get_report_for_gateway(id, {broken_down_by: broken_down, from_day: from_day },
        self.aggregate_customs.only_gateways.map(&:removable_id))
      .map(&:obj_id).uniq
      ids.each do |c_id|
        track_children(c_id, DataEntryway, broken_down, from_day)
      end
      remove_children = true
    else
      ids = SummaryListen.get_report_for_gateway(id, {broken_down_by: broken_down, from_day: from_day },
        self.aggregate_customs.only_entryways.map(&:removable_id))
      .map(&:obj_id).uniq
      remove_children = false
    end
    ids.each do |c_id|
      self.aggregate_customs.create(removable_id: c_id, removable_type: c_klass.to_s, remove_children: remove_children)
    end
  end

  # list with format: ["3_true"], first item => id, last_item => remove_children
  # klass: for polymorphic
  def remove_removal_item(list, c_list, klass)
    if list.present?
      if klass == DataGroupCountry
        # destroy list of countries
        self.aggregate_customs.only_countries.where(removable_id: list).delete_all
        # find and destroy all removed item is gateway children
        gateway_ids = DataGateway.where(country_id: list).select("id").map(&:id)
        self.aggregate_customs.only_gateways.where(removable_id: gateway_ids).delete_all if gateway_ids.present?
        # find and destroy all removed item is entryway children
        entryway_ids = DataGateway.where(id: gateway_ids).joins(:data_entryways).select("data_entryway.id").uniq.map(&:id)
        self.aggregate_customs.only_entryways.where(removable_id: entryway_ids).delete_all if entryway_ids.present?
      end

      if klass == DataGateway
        # destroy list of gateways
        self.aggregate_customs.only_gateways.where(removable_id: list).delete_all
        # find and destroy all removed item is entryway children
        entryway_ids = DataGateway.where(id: list).joins(:data_entryways).select("data_entryway.id").uniq.map(&:id)
        self.aggregate_customs.only_entryways.where(removable_id: entryway_ids).delete_all if entryway_ids.present?
      end

      AggregateCustom.by_type(klass.to_s).where(removable_id: list).delete_all if(klass == DataEntryway)
    end
  end

  protected
  def should_save_accessors_on
    self.should_save_accessors = true
    true
  end

  def should_save_accessors_off
    self.should_save_accessors = false
    true
  end
end

# == Schema Information
#
# Table name: sys_user
#
#  id                     :integer          not null, primary key
#  title                  :string(200)
#  permission_id          :integer
#  password               :string(200)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  failed_attempts        :integer          default(0)
#  unlock_token           :string(255)
#  locked_at              :datetime
#  created_at             :datetime
#  updated_at             :datetime
#
# Indexes
#
#  fk_sys_user_1_idx                       (permission_id)
#  index_sys_user_on_email                 (email) UNIQUE
#  index_sys_user_on_reset_password_token  (reset_password_token) UNIQUE
#  index_sys_user_on_unlock_token          (unlock_token) UNIQUE
#

