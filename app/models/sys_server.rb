class SysServer < ActiveRecord::Base
  # attr_accessible :title, :body
end

# == Schema Information
#
# Table name: sys_server
#
#  id                           :integer          not null, primary key
#  title                        :string(200)
#  short_title                  :string(16)
#  ip                           :string(15)
#  location_id                  :integer
#  engine_listen_remote_ip      :string(200)
#  engine_talk_remote_ip        :string(200)
#  engine_privatetalk_remote_ip :string(200)
#  engine_media_remote_ip       :string(200)
#  engine_advertise_remote_ip   :string(200)
#  is_deleted                   :boolean          default(FALSE)
#
# Indexes
#
#  fk_sys_server_1_idx  (location_id)
#

