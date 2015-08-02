class DataGroup3rdparty < ActiveRecord::Base
  self.table_name = :data_group_3rdparty
  attr_accessible :title

  # SHARED METHODS
  include ::SharedMethods
  validates_presence_of :title
  has_many :data_entryways, foreign_key: '3rdparty_id'
  has_many :entryways, class_name: "DataEntryway", foreign_key: '3rdparty_id'
  accepts_nested_attributes_for :data_entryways

  def refresh_entryways(selected_ids)
    # self.entryways.update_all("3rdparty_id" => nil)
    return true unless selected_ids.present?
    selected_ids.each do |selected_id|
      entryway = DataEntryway.find_by_id(selected_id)
      entryway.update_attributes("3rdparty_id" => id)
    end
  end
end

# == Schema Information
#
# Table name: data_group_3rdparty
#
#  id         :integer          not null, primary key
#  title      :string(200)
#  is_deleted :boolean          default(FALSE)
#

