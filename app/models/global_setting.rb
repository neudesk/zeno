class GlobalSetting < ActiveRecord::Base
  attr_accessible :group, :name, :value
  validates :group, :name, :value, :presence => true

  def self.get_signup_configs
    self.where(:group => 'GLOBAL_SIGNUP_CONFIGS')
  end

  def self.update_config(name, value)
    config = self.find_by_name(name)
    if config.present?
      config.update_attributes(:value => value)
    end
  end

  def self.create_default_did_configs(params, schedule)
    CAMPAIGNS_LOG.debug "============== Start: Scheduling Default CLEC ===================="
    CAMPAIGNS_LOG.debug "scheduled on: #{schedule.strftime('%Y-%m-%d %H:%M')}"
    configs = self.where(group: 'DEFAULT_DID_CONFIGS')
    configs.delete_all
    CAMPAIGNS_LOG.info self.create(group: 'DEFAULT_DID_CONFIGS', 
                                   name: 'primary_campaign_default_did_provider', 
                                   value: params[:primary_campaign_default_did_provider]).to_json
    CAMPAIGNS_LOG.info self.create(group: 'DEFAULT_DID_CONFIGS', 
                                   name: 'secondary_campaign_default_did_provider', 
                                   value: params[:secondary_campaign_default_did_provider]).to_json
    CAMPAIGNS_LOG.info self.create(group: 'DEFAULT_DID_CONFIGS', 
                                   name: 'default_did_provider_setting_schedule', 
                                   value: schedule.strftime('%Y-%m-%d %H:%M')).to_json
  end

  def self.get_default_did_configs
    self.where(group: 'DEFAULT_DID_CONFIGS')
  end


end
