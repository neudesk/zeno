class StationTool < ActiveRecord::Base

  include PublicActivity::Model

  has_attached_file :background, {
      :styles => {
          :thumb => ["80x80#", :png]
      }
  }
  has_attached_file :logo, {
      :styles => {
          :thumb => ["80x80#", :png]
      }
  }
  attr_accessible :tool_type, :is_customized, :station_name, :station_description, :station_website, :phone_number_display,
                  :did, :is_auto_play, :channel_to_auto_play, :player_height, :player_width, :player_volume, :logo, :background,
                  :additional_info, :tagline, :channeling_type
  validates :tool_type, :presence => true
  validates :station_name, :presence => true
  validates :phone_number_display, :presence => true
  # validates :did, :presence => true
  validates_attachment :background, content_type: { content_type: ["image/jpg", "image/jpeg", "image/gif", "image/png"], :message => 'Background is in invalid format. Allowed formats are .jpg, .jpeg, .gif and .png' }
  validates_attachment :logo, content_type: { content_type: ["image/jpg", "image/jpeg", "image/gif", "image/png"], :message => 'Logo is in invalid format. Allowed formats are .jpg, .jpeg, .gif and .png' }
end
