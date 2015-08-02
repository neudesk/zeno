# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150730183543) do

  create_table "activities", :force => true do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "trackable_title"
    t.string   "user_title"
    t.string   "sec_trackable_type"
    t.string   "sec_trackable_title"
  end

  add_index "activities", ["owner_id", "owner_type"], :name => "index_activities_on_owner_id_and_owner_type"
  add_index "activities", ["recipient_id", "recipient_type"], :name => "index_activities_on_recipient_id_and_recipient_type"
  add_index "activities", ["trackable_id", "trackable_type"], :name => "index_activities_on_trackable_id_and_trackable_type"

  create_table "admin_dnc_list", :force => true do |t|
    t.integer  "listener_id"
    t.string   "phone_number"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "admin_dnc_list", ["phone_number"], :name => "phone_number"

  create_table "admin_setting", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "bad_listener", :force => true do |t|
    t.string   "ani_e164",      :null => false
    t.string   "clec"
    t.string   "carrier"
    t.string   "assigned_clec"
    t.string   "gateway_id"
    t.string   "assigned_did"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "data_carrier_rule", :force => true do |t|
    t.integer  "gateway_id",               :limit => 8
    t.integer  "entryway_provider_id",     :limit => 8
    t.integer  "parent_carrier_id",        :limit => 8
    t.integer  "gateway_prompt_id",        :limit => 8
    t.boolean  "hangup_after_play",                     :default => true
    t.integer  "new_entryway_provider_id", :limit => 8
    t.boolean  "is_enabled",                            :default => true
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
  end

  add_index "data_carrier_rule", ["entryway_provider_id"], :name => "idx_data_carrier_rule_6"
  add_index "data_carrier_rule", ["gateway_id", "entryway_provider_id", "parent_carrier_id"], :name => "u_gateway_clec_carrier", :unique => true
  add_index "data_carrier_rule", ["gateway_id"], :name => "idx_data_carrier_rule_5"
  add_index "data_carrier_rule", ["gateway_prompt_id"], :name => "idx_data_carrier_rule_8"
  add_index "data_carrier_rule", ["new_entryway_provider_id"], :name => "idx_data_carrier_rule_9"
  add_index "data_carrier_rule", ["parent_carrier_id"], :name => "idx_data_carrier_rule_7"

  create_table "data_content", :force => true do |t|
    t.boolean   "is_deleted",                                                                              :default => false
    t.integer   "broadcast_id",                                 :limit => 8
    t.integer   "country_id",                                   :limit => 8
    t.integer   "language_id",                                  :limit => 8
    t.integer   "genre_id",                                     :limit => 8
    t.text      "info"
    t.string    "title"
    t.timestamp "date_last_change"
    t.boolean   "flag_no_listener_preroll_ad",                                                             :default => false
    t.boolean   "flag_no_listener_timeout_ad",                                                             :default => false
    t.string    "media_type",                                   :limit => 16,                              :default => "FFMPEG"
    t.string    "media_url"
    t.integer   "media_volume_percent",                                                                    :default => 100
    t.boolean   "media_volume_mute",                                                                       :default => false
    t.enum      "media_status",                                 :limit => [:STOP, :PLAYING],               :default => :PLAYING
    t.boolean   "onair_active",                                                                            :default => false
    t.string    "onair_title"
    t.boolean   "chat_active",                                                                             :default => true
    t.string    "chat_title"
    t.boolean   "poll_active",                                                                             :default => false
    t.string    "poll_title"
    t.enum      "poll_mode",                                    :limit => [:SINGLEVOTE, :MULTIPLEVOTES],   :default => :SINGLEVOTE
    t.datetime  "poll_lastupdate"
    t.integer   "poll_listeners_count",                                                                    :default => 0
    t.string    "poll_option_1_title"
    t.integer   "poll_option_1_count",                                                                     :default => 0
    t.string    "poll_option_2_title"
    t.integer   "poll_option_2_count",                                                                     :default => 0
    t.string    "poll_option_3_title"
    t.integer   "poll_option_3_count",                                                                     :default => 0
    t.string    "brand_text_color",                             :limit => 32
    t.string    "brand_logo_url"
    t.integer   "brand_logo_blob_id",                           :limit => 8
    t.string    "brand_background_color",                       :limit => 32
    t.string    "brand_background_mode",                        :limit => 32
    t.string    "brand_background_url"
    t.integer   "brand_background_blob_id",                     :limit => 8
    t.boolean   "player_cache_on"
    t.boolean   "interactive_poll_active",                                                                 :default => false
    t.enum      "interactive_poll_mode",                        :limit => [:SINGLEVOTE, :MULTIPLEVOTES],   :default => :SINGLEVOTE
    t.datetime  "interactive_poll_lastupdate"
    t.integer   "interactive_poll_listeners_count",                                                        :default => 0
    t.integer   "interactive_poll_opt_1",                                                                  :default => 0
    t.integer   "interactive_poll_opt_2",                                                                  :default => 0
    t.integer   "interactive_poll_opt_3",                                                                  :default => 0
    t.boolean   "interactive_handup_active",                                                               :default => true
    t.boolean   "advertise_trigger_enable_listenerpreroll",                                                :default => true
    t.boolean   "advertise_trigger_enable_listenertimeout",                                                :default => true
    t.boolean   "advertise_trigger_enable_conferencetiemout",                                              :default => false
    t.boolean   "advertise_trigger_enable_conferenceadreplace",                                            :default => false
    t.boolean   "flag_no_ad",                                                                              :default => false
    t.enum      "status",                                       :limit => [:down_permanently, :down, :up]
    t.string    "status_message",                               :limit => 512
    t.datetime  "last_checked"
    t.string    "backup_media_url"
    t.datetime  "state_changed"
    t.string    "player_text_color",                            :limit => 32
    t.string    "player_logo_url"
    t.string    "player_background_color",                      :limit => 32
    t.string    "player_background_mode",                       :limit => 32
    t.string    "player_background_url"
    t.integer   "minutes_30_days",                              :limit => 8,                               :default => 0,           :null => false
    t.string    "website"
    t.boolean   "disable_stream",                                                                          :default => false
    t.boolean   "radiojar_enabled"
    t.string    "radiojar_mount"
    t.string    "radiojar_key"
    t.boolean   "is_media_quality_on",                                                                     :default => false
    t.boolean   "media_quality_active",                                                                    :default => false
  end

  add_index "data_content", ["broadcast_id"], :name => "fk_data_content_1_idx"
  add_index "data_content", ["country_id"], :name => "fk_data_content_1_idx1"
  add_index "data_content", ["genre_id"], :name => "gener_idx"
  add_index "data_content", ["language_id"], :name => "fk_data_content_1_idx2"
  add_index "data_content", ["status"], :name => "status_idx"

  create_table "data_content_off_air", :force => true do |t|
    t.integer  "content_id"
    t.integer  "day"
    t.time     "time_start"
    t.time     "time_end"
    t.string   "stream_url"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "stream_file_name"
    t.string   "stream_content_type"
    t.integer  "stream_file_size"
    t.datetime "stream_updated_at"
  end

  create_table "data_entryway", :force => true do |t|
    t.string    "title",                       :limit => 200
    t.string    "did_e164",                    :limit => 32
    t.integer   "gateway_id",                  :limit => 8
    t.integer   "country_id",                  :limit => 8
    t.integer   "3rdparty_id",                 :limit => 8
    t.integer   "entryway_provider",           :limit => 8
    t.boolean   "is_deleted",                                 :default => false
    t.boolean   "is_default",                                 :default => false
    t.boolean   "flag_no_listener_preroll_ad",                :default => false
    t.boolean   "flag_no_listener_timeout_ad",                :default => false
    t.boolean   "flag_no_ad",                                 :default => false
    t.timestamp "date_last_change"
  end

  add_index "data_entryway", ["3rdparty_id"], :name => "fk_data_entryway_1_idx2"
  add_index "data_entryway", ["country_id"], :name => "fk_data_entryway_1_idx3"
  add_index "data_entryway", ["did_e164"], :name => "DID"
  add_index "data_entryway", ["entryway_provider"], :name => "fk_data_entryway_1_idx"
  add_index "data_entryway", ["gateway_id"], :name => "fk_data_entryway_1_idx1"
  add_index "data_entryway", ["gateway_id"], :name => "idx_gateway"
  add_index "data_entryway", ["title"], :name => "title"

  create_table "data_entryway_provider", :force => true do |t|
    t.string  "title",         :limit => 200
    t.integer "warning_level"
  end

  create_table "data_gateway", :force => true do |t|
    t.string    "title",                             :limit => 200
    t.integer   "country_id",                        :limit => 8
    t.integer   "language_id",                       :limit => 8
    t.integer   "broadcast_id",                      :limit => 8
    t.integer   "rca_id",                            :limit => 8
    t.integer   "rca_monitor_id",                    :limit => 8
    t.boolean   "is_deleted",                                                             :default => false
    t.enum      "empty_extension_rule",              :limit => [:ASK_AGAIN, :PLAY_FIRST], :default => :PLAY_FIRST
    t.integer   "empty_extension_threshold_count",   :limit => 1,                         :default => 2
    t.enum      "invalid_extension_rule",            :limit => [:ASK_AGAIN, :PLAY_FIRST], :default => :PLAY_FIRST
    t.integer   "invalid_extension_threshold_count", :limit => 1,                         :default => 3
    t.boolean   "ivr_welcome_enabled",                                                    :default => true
    t.integer   "ivr_welcome_prompt_id",             :limit => 8
    t.integer   "ivr_extension_ask_prompt_id",       :limit => 8
    t.boolean   "ivr_extension_invalid_enabled",                                          :default => true
    t.integer   "ivr_extension_invalid_prompt_id",   :limit => 8
    t.boolean   "flag_no_listener_preroll_ad",                                            :default => false
    t.boolean   "flag_no_listener_timeout_ad",                                            :default => false
    t.boolean   "flag_no_ad",                                                             :default => false
    t.timestamp "date_last_change"
    t.string    "info"
    t.string    "brand_text_color",                  :limit => 32
    t.string    "brand_logo_url"
    t.integer   "brand_logo_blob_id",                :limit => 8
    t.string    "brand_background_color",            :limit => 32
    t.string    "brand_background_mode",             :limit => 32
    t.string    "brand_background_url"
    t.integer   "brand_background_blob_id",          :limit => 8
    t.boolean   "flag_broadcaster"
    t.string    "website"
    t.string    "facebook"
    t.string    "twitter"
    t.integer   "data_entryway_id"
    t.string    "logo_file_name"
    t.string    "logo_content_type"
    t.integer   "logo_file_size"
    t.datetime  "logo_updated_at"
    t.string    "player_text_color",                 :limit => 32
    t.string    "player_logo_url"
    t.string    "player_background_color",           :limit => 32
    t.string    "player_background_mode",            :limit => 32
    t.string    "player_background_url"
    t.integer   "player_autoplay",                                                        :default => 0
    t.integer   "player_zeno_logo",                  :limit => 1,                         :default => 0
    t.string    "metadata"
    t.boolean   "widget_is_set_up",                                                       :default => false
  end

  add_index "data_gateway", ["broadcast_id"], :name => "fk_data_gateway_3_idx"
  add_index "data_gateway", ["country_id"], :name => "fk_data_gateway_1_idx"
  add_index "data_gateway", ["ivr_extension_ask_prompt_id"], :name => "idx_data_gateway_6"
  add_index "data_gateway", ["ivr_extension_invalid_prompt_id"], :name => "idx_data_gateway_7"
  add_index "data_gateway", ["ivr_welcome_prompt_id"], :name => "idx_data_gateway_5"
  add_index "data_gateway", ["language_id"], :name => "fk_data_gateway_2_idx"
  add_index "data_gateway", ["rca_id"], :name => "fk_data_gateway_4_idx"
  add_index "data_gateway", ["rca_monitor_id"], :name => "idx_data_gateway_1"

  create_table "data_gateway_conference", :force => true do |t|
    t.integer "gateway_id", :limit => 8
    t.integer "content_id", :limit => 8
    t.string  "extension",  :limit => 16
  end

  add_index "data_gateway_conference", ["content_id"], :name => "fk_data_gateway_content_2_idx"
  add_index "data_gateway_conference", ["gateway_id"], :name => "fk_data_gateway_content_1_idx"

  create_table "data_gateway_note", :force => true do |t|
    t.string   "user_id"
    t.string   "gateway_id"
    t.text     "note",                          :null => false
    t.boolean  "is_deleted", :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "data_gateway_prompt", :force => true do |t|
    t.string    "title",            :limit => 200
    t.integer   "gateway_id",       :limit => 8
    t.integer   "media_kb",                        :default => 0
    t.integer   "media_seconds",                   :default => 0
    t.timestamp "date_last_change"
  end

  add_index "data_gateway_prompt", ["gateway_id"], :name => "idx_data_gateway_prompt_1"

  create_table "data_group_3rdparty", :force => true do |t|
    t.string  "title",      :limit => 200
    t.boolean "is_deleted",                :default => false
  end

  create_table "data_group_broadcast", :force => true do |t|
    t.string  "title",                  :limit => 200
    t.boolean "is_deleted",                            :default => false
    t.boolean "reachout_tab_is_active"
    t.boolean "upload_list_is_active"
    t.boolean "opt_in_is_active"
  end

  create_table "data_group_country", :force => true do |t|
    t.string  "title",          :limit => 200
    t.string  "iso_alpha_2",    :limit => 2
    t.string  "iso_alpha_3",    :limit => 3
    t.string  "iso_numeric",    :limit => 3
    t.boolean "is_deleted",                    :default => false
    t.string  "continent_code"
  end

  create_table "data_group_genre", :force => true do |t|
    t.string  "title",      :limit => 200
    t.boolean "is_deleted",                :default => false
  end

  create_table "data_group_language", :force => true do |t|
    t.string  "title",      :limit => 200
    t.boolean "is_deleted",                :default => false
  end

  create_table "data_group_rca", :force => true do |t|
    t.string  "title",                  :limit => 200
    t.boolean "is_deleted",                            :default => false
    t.boolean "reachout_tab_is_active"
    t.boolean "upload_list_is_active"
    t.boolean "opt_in_is_active"
  end

  create_table "data_listener_ani_carrier", :force => true do |t|
    t.string "title", :limit => 200
    t.string "OCN",   :limit => 32
  end

  add_index "data_listener_ani_carrier", ["OCN"], :name => "index2", :unique => true

  create_table "data_listener_at_gateway", :force => true do |t|
    t.integer   "listener_id",                            :limit => 8
    t.integer   "context_at_id",                          :limit => 8
    t.timestamp "statistics_first_session_date"
    t.datetime  "statistics_last_session_date"
    t.string    "statistics_last_sessions_timestamp",     :limit => 1024
    t.string    "statistics_last_sessions_log_listen_id", :limit => 1024
    t.integer   "statistics_sessions_count",              :limit => 8
    t.integer   "statistics_sessions_seconds",            :limit => 8
  end

  add_index "data_listener_at_gateway", ["context_at_id"], :name => "idx_data_listener_at_gateway_2"
  add_index "data_listener_at_gateway", ["listener_id"], :name => "idx_data_listener_at_gateway_1"
  add_index "data_listener_at_gateway", ["statistics_last_session_date"], :name => "index4"

  create_table "data_parent_carrier", :force => true do |t|
    t.string "title", :limit => 40
  end

  add_index "data_parent_carrier", ["title"], :name => "title", :unique => true

  create_table "default_prompt", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "prompt_file_name"
    t.string   "prompt_content_type"
    t.integer  "prompt_file_size"
    t.datetime "prompt_updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "global_setting", :force => true do |t|
    t.string "group"
    t.string "name"
    t.string "value"
  end

  create_table "log_call", :force => true do |t|
    t.integer  "server_id",             :limit => 8
    t.enum     "type",                  :limit => [:PHONE, :WIDGET, :ANDROID, :IOS], :default => :PHONE
    t.string   "asterisk_remote_ip",    :limit => 15
    t.string   "widget_listener_ip",    :limit => 15
    t.string   "widget_refer",          :limit => 128
    t.datetime "date_start"
    t.datetime "date_stop"
    t.integer  "seconds"
    t.string   "ani_e164",              :limit => 64
    t.string   "did_e164",              :limit => 64
    t.integer  "listener_id",           :limit => 8
    t.integer  "listener_ani_id",       :limit => 8
    t.integer  "listener_token_id",     :limit => 8
    t.boolean  "listener_is_anonymous",                                              :default => false
    t.integer  "entryway_id",           :limit => 8
    t.integer  "gateway_id",            :limit => 8
    t.boolean  "on_summary",                                                         :default => false
  end

  add_index "log_call", ["date_start"], :name => "date_start"
  add_index "log_call", ["date_stop"], :name => "date_stop"
  add_index "log_call", ["entryway_id", "date_start"], :name => "entryway"
  add_index "log_call", ["gateway_id", "date_start"], :name => "gateway"
  add_index "log_call", ["listener_ani_id", "date_start"], :name => "list_ani"
  add_index "log_call", ["listener_id", "date_start"], :name => "listener"
  add_index "log_call", ["on_summary"], :name => "on_summary"
  add_index "log_call", ["server_id", "date_start"], :name => "server"

  create_table "now_session", :force => true do |t|
    t.integer  "log_call_id",                                          :limit => 8
    t.integer  "log_listen_id",                                        :limit => 8
    t.integer  "log_campaign_id",                                      :limit => 8
    t.integer  "log_campaign_siptransfer_id",                          :limit => 8
    t.string   "device_user_agent",                                    :limit => 128
    t.boolean  "device_has_microphone",                                                                                                                                                                                :default => false
    t.string   "device_listener_ip",                                   :limit => 15
    t.string   "device_website",                                       :limit => 128
    t.integer  "call_server_id",                                       :limit => 8
    t.enum     "call_type",                                            :limit => [:PHONE, :WIDGET, :ANDROID, :IOS],                                                                                                    :default => :PHONE
    t.datetime "call_date_start"
    t.string   "call_asterisk_sip_ip",                                 :limit => 15
    t.string   "call_asterisk_channel",                                :limit => 64
    t.string   "call_asterisk_uniqueid",                               :limit => 64
    t.string   "call_widget_refer",                                    :limit => 128
    t.string   "call_widget_listener_ip",                              :limit => 15
    t.string   "call_ani_e164",                                        :limit => 32
    t.string   "call_did_e164",                                        :limit => 32
    t.string   "call_token",                                           :limit => 64
    t.boolean  "call_listener_play_welcome",                                                                                                                                                                           :default => true
    t.integer  "call_listener_token_id",                               :limit => 8
    t.integer  "call_listener_ani_id",                                 :limit => 8
    t.integer  "call_listener_id",                                     :limit => 8
    t.boolean  "call_listener_is_anonymous"
    t.integer  "call_entryway_id",                                     :limit => 8
    t.integer  "call_gateway_id",                                      :limit => 8
    t.boolean  "listen_active",                                                                                                                                                                                        :default => false
    t.datetime "listen_date_start"
    t.string   "listen_extension",                                     :limit => 16
    t.integer  "listen_content_id",                                    :limit => 8
    t.integer  "listen_gateway_conference_id",                         :limit => 8
    t.integer  "listen_server_id",                                     :limit => 8
    t.integer  "listen_last_played_campaign_id",                       :limit => 8
    t.datetime "listen_last_played_campaign_timestamp"
    t.integer  "listen_last_played_campaign_log_id",                   :limit => 8
    t.string   "listen_last_played_campaigns_interruption_timestamps"
    t.string   "listen_last_played_campaigns_interruption_ids"
    t.string   "listen_asterisk_channel",                              :limit => 64
    t.string   "listen_asterisk_uniqueid",                             :limit => 64
    t.boolean  "listen_interactive_handup_active",                                                                                                                                                                     :default => false
    t.datetime "listen_interactive_handup_active_timestamp"
    t.integer  "listen_interactive_handup_count",                                                                                                                                                                      :default => 0
    t.integer  "listen_interactive_poll_opt_1",                                                                                                                                                                        :default => 0
    t.integer  "listen_interactive_poll_opt_2",                                                                                                                                                                        :default => 0
    t.integer  "listen_interactive_poll_opt_3",                                                                                                                                                                        :default => 0
    t.datetime "listen_interactive_poll_lastchange"
    t.integer  "listen_interactive_status_talk_count",                                                                                                                                                                 :default => 0
    t.integer  "listen_interactive_status_privatetalk_count",                                                                                                                                                          :default => 0
    t.enum     "engine_type",                                          :limit => [:LISTEN, :TALK, :PRIVATETALK, :ADVERTISE, :ADVERTISESIPTRANSFER, :HANGUP]
    t.datetime "engine_date_start"
    t.integer  "engine_server_id",                                     :limit => 8
    t.string   "engine_asterisk_channel",                              :limit => 64
    t.string   "engine_asterisk_uniqueid",                             :limit => 64
    t.string   "engine_sip_call_id"
    t.string   "engine_mpe_id"
    t.enum     "engine_advertise_trigger_type",                        :limit => [:LISTENERMANUAL, :LISTENERTIMEOUT, :LISTENERPREROLL, :LISTENERREQUEST, :CONFERENCEMANUAL, :CONFERENCETIMEOUT, :CONFERENCEADREPLACE]
    t.integer  "engine_campaign_id",                                   :limit => 8
    t.enum     "next_step_1_engine_type",                              :limit => [:LISTEN, :TALK, :PRIVATETALK, :ADVERTISE, :ADVERTISESIPTRANSFER, :HANGUP]
    t.enum     "next_step_1_engine_advertise_trigger_type",            :limit => [:LISTENERMANUAL, :LISTENERTIMEOUT, :LISTENERPREROLL, :LISTENERREQUEST, :CONFERENCEMANUAL, :CONFERENCETIMEOUT, :CONFERENCEADREPLACE]
    t.integer  "next_step_1_engine_campaign_id",                       :limit => 8
    t.enum     "next_step_2_engine_type",                              :limit => [:LISTEN, :TALK, :PRIVATETALK, :ADVERTISE, :ADVERTISESIPTRANSFER, :HANGUP]
    t.enum     "next_step_2_engine_advertise_trigger_type",            :limit => [:LISTENERMANUAL, :LISTENERTIMEOUT, :LISTENERPREROLL, :LISTENERREQUEST, :CONFERENCEMANUAL, :CONFERENCETIMEOUT, :CONFERENCEADREPLACE]
    t.integer  "next_step_2_engine_campaign_id",                       :limit => 8
    t.enum     "last_engine_type",                                     :limit => [:LISTEN, :TALK, :PRIVATETALK, :ADVERTISE, :ADVERTISESIPTRANSFER, :HANGUP]
    t.enum     "last_engine_advertise_trigger_type",                   :limit => [:LISTENERMANUAL, :LISTENERTIMEOUT, :LISTENERPREROLL, :LISTENERREQUEST, :CONFERENCEMANUAL, :CONFERENCETIMEOUT, :CONFERENCEADREPLACE]
    t.integer  "last_engine_campaign_id",                              :limit => 8
    t.integer  "talk_volume_percent",                                                                                                                                                                                  :default => 100
    t.integer  "listen_volume_percent",                                                                                                                                                                                :default => 100
  end

  add_index "now_session", ["call_asterisk_channel", "call_server_id"], :name => "search_call_by_channel"
  add_index "now_session", ["call_date_start"], :name => "date_start"
  add_index "now_session", ["call_server_id"], :name => "call_server"

  create_table "pending_users", :force => true do |t|
    t.string   "station_name"
    t.string   "company_name"
    t.string   "streaming_url"
    t.string   "status",          :default => "unprocessed"
    t.string   "website"
    t.string   "genre"
    t.string   "language"
    t.string   "name"
    t.string   "email"
    t.string   "facebook"
    t.string   "twitter"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.datetime "signup_date"
    t.text     "note"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.datetime "date_processed"
    t.string   "affiliate"
    t.string   "rca"
    t.boolean  "enabled",         :default => true
    t.string   "on_air_schedule"
    t.string   "zip_code"
    t.string   "cellphone"
    t.string   "landline"
    t.string   "service_type"
  end

  create_table "reachout_tab_campaign", :force => true do |t|
    t.integer  "gateway_id"
    t.integer  "did_e164",            :limit => 8
    t.boolean  "generic_prompt"
    t.datetime "schedule_start_date"
    t.datetime "schedule_end_date"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "prompt_file_name"
    t.string   "prompt_content_type"
    t.integer  "prompt_file_size"
    t.datetime "prompt_updated_at"
    t.string   "campaign_id"
    t.string   "status"
    t.integer  "created_by"
    t.integer  "main_id"
    t.integer  "listeners_no"
    t.string   "did_provider"
    t.string   "carrier_title"
    t.boolean  "campaign_saved"
    t.string   "dpaste_link"
  end

  add_index "reachout_tab_campaign", ["gateway_id"], :name => "gateway_id"

  create_table "reachout_tab_campaign_listener", :force => true do |t|
    t.integer  "campaign_id"
    t.string   "phone_number"
    t.datetime "campaign_date"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "gateway_id"
  end

  add_index "reachout_tab_campaign_listener", ["phone_number"], :name => "phone_number"

  create_table "reachout_tab_listener_minutes_by_gateway", :force => true do |t|
    t.integer  "listener_id"
    t.string   "ani_e164"
    t.integer  "gateway_id"
    t.string   "did_e164"
    t.integer  "minutes"
    t.datetime "created_at",                   :null => false
    t.integer  "carrier_id",      :limit => 8
    t.string   "carrier_title"
    t.integer  "listener_ani_id", :limit => 8
    t.string   "did_title"
  end

  add_index "reachout_tab_listener_minutes_by_gateway", ["ani_e164"], :name => "ani_e164"

  create_table "reachout_tab_listener_minutes_by_gateway_copy", :id => false, :force => true do |t|
    t.integer  "id",              :limit => 8, :default => 0, :null => false
    t.integer  "listener_id"
    t.string   "ani_e164"
    t.integer  "gateway_id"
    t.string   "did_e164"
    t.integer  "minutes"
    t.datetime "created_at",                                  :null => false
    t.integer  "carrier_id",      :limit => 8
    t.string   "carrier_title"
    t.integer  "listener_ani_id", :limit => 8
    t.string   "did_title"
  end

  create_table "reachout_tab_mapping_rule", :force => true do |t|
    t.integer  "carrier_id",        :limit => 8
    t.string   "carrier_title"
    t.integer  "entryway_id",       :limit => 8
    t.string   "entryway_provider"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "reachout_tab_mapping_rule", ["carrier_title", "entryway_provider"], :name => "carrier_clec_index", :unique => true

  create_table "reachout_tab_multi_mapping_rules", :force => true do |t|
    t.integer  "carrier_id",        :limit => 8
    t.string   "carrier_title"
    t.integer  "entryway_id",       :limit => 8
    t.string   "entryway_provider"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "reachout_tab_multi_mapping_rules", ["carrier_title", "entryway_provider"], :name => "carrier_clec_index", :unique => true

  create_table "report_listener_by_gateway_id", :force => true do |t|
    t.integer  "gateway_id"
    t.integer  "total_listeners"
    t.datetime "created_at",      :null => false
  end

  create_table "report_listener_totals", :force => true do |t|
    t.integer  "sys_user_id"
    t.integer  "total_listeners"
    t.datetime "created_at",      :null => false
  end

  create_table "report_summary_listen", :force => true do |t|
    t.date     "report_date"
    t.integer  "total_minutes"
    t.integer  "gateway_id"
    t.integer  "content_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "report_summary_listen", ["report_date"], :name => "idx_report_summary_listen_1"

  create_table "report_total_minutes_by_day", :force => true do |t|
    t.date     "report_date"
    t.integer  "gateway_id"
    t.integer  "total_minutes",  :default => 0
    t.integer  "phone_minutes",  :default => 0
    t.integer  "widget_minutes", :default => 0
    t.integer  "app_minutes",    :default => 0
    t.datetime "created_at",                    :null => false
  end

  add_index "report_total_minutes_by_day", ["gateway_id", "report_date"], :name => "u_report_total_minutes_by_day_1", :unique => true

  create_table "report_total_minutes_by_hour", :force => true do |t|
    t.integer  "report_hours"
    t.integer  "total_minutes"
    t.integer  "gateway_id"
    t.datetime "created_at",    :null => false
    t.date     "report_date"
  end

  create_table "report_total_minutes_by_hour_actual", :force => true do |t|
    t.date     "report_date"
    t.integer  "report_hours"
    t.integer  "gateway_id"
    t.integer  "total_minutes",  :default => 0
    t.integer  "phone_minutes",  :default => 0
    t.integer  "widget_minutes", :default => 0
    t.integer  "app_minutes",    :default => 0
    t.datetime "created_at",                    :null => false
  end

  add_index "report_total_minutes_by_hour_actual", ["report_date", "gateway_id", "report_hours"], :name => "u_report_total_minutes_by_hour_actual_1", :unique => true

  create_table "station_tool", :force => true do |t|
    t.string   "tool_type"
    t.string   "station_name"
    t.text     "station_description"
    t.string   "station_website"
    t.string   "phone_number_display"
    t.string   "did"
    t.boolean  "is_auto_play",            :default => false
    t.string   "channel_to_auto_play"
    t.string   "player_height"
    t.string   "player_width"
    t.float    "player_volume"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "additional_info"
    t.string   "channeling_type",         :default => "single"
    t.boolean  "is_customized",           :default => false
    t.string   "background_file_name"
    t.string   "logo_file_name"
    t.integer  "background_file_size"
    t.integer  "logo_file_size"
    t.string   "background_content_type"
    t.string   "logo_content_type"
    t.datetime "background_updated_at"
    t.datetime "logo_updated_at"
    t.string   "tagline"
  end

  create_table "summary_call", :force => true do |t|
    t.datetime "date"
    t.integer  "entryway_id",             :limit => 8
    t.integer  "listener_ani_carrier_id", :limit => 8
    t.integer  "count",                   :limit => 3
    t.integer  "seconds",                 :limit => 3
  end

  add_index "summary_call", ["date"], :name => "date"
  add_index "summary_call", ["entryway_id"], :name => "e"
  add_index "summary_call", ["listener_ani_carrier_id"], :name => "c"

  create_table "sys_config", :id => false, :force => true do |t|
    t.string "group", :limit => 64,  :null => false
    t.string "name",  :limit => 128, :null => false
    t.string "value"
  end

  create_table "sys_user", :force => true do |t|
    t.integer  "permission_id",          :limit => 8
    t.string   "title"
    t.string   "email",                               :default => "",    :null => false
    t.string   "encrypted_password",                  :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",                     :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "address"
    t.string   "barcode"
    t.string   "signup_facebook"
    t.string   "signup_twitter"
    t.string   "signup_rca"
    t.string   "signup_station_name"
    t.string   "signup_streaming_url"
    t.string   "signup_website"
    t.string   "signup_language"
    t.string   "signup_genre"
    t.string   "signup_affiliate"
    t.string   "signup_on_air_schedule"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.string   "country"
    t.string   "backup_email"
    t.string   "landline"
    t.string   "cellphone"
    t.string   "service_type"
    t.boolean  "enabled"
    t.boolean  "is_deleted"
    t.integer  "country_id",             :limit => 8
    t.string   "photo_url"
    t.boolean  "is_auto_signup",                      :default => false
    t.boolean  "email_verified",                      :default => true
  end

  add_index "sys_user", ["permission_id"], :name => "fk_sys_user_1_idx"
  add_index "sys_user", ["permission_id"], :name => "idx_sys_user_1"

  create_table "sys_user_countries", :force => true do |t|
    t.integer "user_id",    :limit => 8
    t.integer "country_id"
  end

  add_index "sys_user_countries", ["user_id", "country_id"], :name => "user_id", :unique => true

  create_table "sys_user_email_verification", :id => false, :force => true do |t|
    t.integer "user_id",        :limit => 8,                     :null => false
    t.string  "token",          :limit => 32,                    :null => false
    t.boolean "login_attempts",               :default => false, :null => false
  end

  create_table "sys_user_permission", :force => true do |t|
    t.string  "title",                                   :limit => 200
    t.boolean "is_super_user",                                          :default => false
    t.boolean "can_manage_specific_3rdparty_resources",                 :default => false
    t.boolean "can_manage_specific_broadcast_resources",                :default => false
    t.boolean "can_manage_specific_rca_resources",                      :default => false
    t.boolean "can_manage_all_zenoradio_data",                          :default => false
    t.boolean "can_manage_all_zenoradio_metadata",                      :default => false
    t.boolean "can_manage_all_zenoradio_users",                         :default => false
  end

  create_table "sys_user_resource_3rdparty", :force => true do |t|
    t.integer "user_id",     :limit => 8
    t.integer "3rdparty_id", :limit => 8
  end

  add_index "sys_user_resource_3rdparty", ["3rdparty_id"], :name => "fk_sys_user_resource_3rdparty_2_idx"
  add_index "sys_user_resource_3rdparty", ["user_id"], :name => "idx_sys_user_resource_3rdparty_1"

  create_table "sys_user_resource_broadcast", :force => true do |t|
    t.integer "user_id",      :limit => 8
    t.integer "broadcast_id", :limit => 8
  end

  add_index "sys_user_resource_broadcast", ["broadcast_id"], :name => "fk_sys_user_resource_broadcast_2_idx"
  add_index "sys_user_resource_broadcast", ["user_id"], :name => "idx_sys_user_resource_broadcast_1"

  create_table "sys_user_resource_rca", :force => true do |t|
    t.integer "user_id", :limit => 8
    t.integer "rca_id",  :limit => 8
  end

  add_index "sys_user_resource_rca", ["rca_id"], :name => "fk_sys_user_resource_rca_1_idx1"
  add_index "sys_user_resource_rca", ["user_id"], :name => "idx_sys_user_resource_rca_1"

  create_table "sys_user_tags", :force => true do |t|
    t.integer "user_id", :limit => 8, :null => false
    t.string  "tag"
  end

  create_table "tags", :force => true do |t|
    t.string "title"
  end

  create_table "tmp_campaign_uploaded_listeners", :force => true do |t|
    t.integer  "ani_e164",         :limit => 8
    t.integer  "main_campaign_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "gateway_id"
  end

  create_table "user_tags", :force => true do |t|
    t.integer "tag_id"
    t.integer "user_id"
  end

  add_index "user_tags", ["tag_id"], :name => "index_user_tags_on_tag_id"
  add_index "user_tags", ["user_id"], :name => "index_user_tags_on_user_id"

end
