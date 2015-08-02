class SysConfig < ActiveRecord::Base
  attr_accessible :group, :name, :value

  validates :value, presence: true
  UI_CONFIG_GROUP = "UI_CONFIG"
  EMAIL_CONFIG = "EMAIL"

  def self.add_config(group, name, value)
    config = self.find_by_group_and_name(group, name)
    if config
      SysConfig.where(:group => "UI_CONFIG").where(:name => "EMAIL").update_all(:value => value)
    else
      SysConfig.create(group: group, name: name, value: value)
    end
  end

  def self.get_config(group, name)
    self.find_by_group_and_name(group, name)
  end

  def self.update_config(name, group = nil, value)
    config = SysConfig.where(:name => name)
    if config.present?
      config = config.first
      config.update_attributes(:value => value)
      unless group.nil?
        config.update_attributes(:group => group)
      end
    end
  end

end