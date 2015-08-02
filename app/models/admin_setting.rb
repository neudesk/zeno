class AdminSetting < ActiveRecord::Base
  attr_accessible :name, :value

  include PublicActivity::Model

  def self.default_campaign_num_of_channels
  	config = self.find_by_name('number_of_channels')
  	unless config.present?
		config = self.create(name: 'number_of_channels', value: '30')
  	end
  	return config.value.to_i
  end

  def self.get_default_clec_config
  	primary = self.find_by_name('primary_campaign_default_did_provider') rescue nil
  	secondary = self.find_by_name('secondary_campaign_default_did_provider') rescue nil
  	return primary, secondary
  end

end
