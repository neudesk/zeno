class DataGroupGenre < ActiveRecord::Base
  attr_accessible :title
  has_many :data_contents, foreign_key: :genre_id
  has_many :contents, class_name: "DataContent", foreign_key: :genre_id

  # SHARED METHODS
  include ::SharedMethods


  def refresh_contents(selected_ids)
    self.contents.update_all(genre_id: nil)
    return true unless selected_ids.present?
    selected_ids.each do |selected_id|
      content = DataContent.find_by_id(selected_id)
      content.update_attributes(genre_id: id)
    end
  end
end

# == Schema Information
#
# Table name: data_group_genre
#
#  id         :integer          not null, primary key
#  title      :string(200)
#  is_deleted :boolean          default(FALSE)
#

