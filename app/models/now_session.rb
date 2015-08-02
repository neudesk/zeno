class NowSession < ActiveRecord::Base
  attr_accessible :log_call_id, :log_listen_id,  :call_server_id, :call_date_start, :call_ani_e164, :call_did_e164, :call_listener_play_welcome, :call_listener_ani_id, :call_listener_id, :call_listener_is_anonymous, :call_entryway_id, :call_gateway_id, :listen_active, :listen_date_start, :listen_extension, :listen_content_id, :listen_gateway_conference_id, :listen_server_id

  belongs_to :data_listener, foreign_key: :call_listener_id
  belongs_to :data_content, foreign_key: :listen_content_id
  belongs_to :data_gateway, foreign_key: :call_gateway_id

end
