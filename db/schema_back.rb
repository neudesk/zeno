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

ActiveRecord::Schema.define(:version => 0) do

  create_table "aggregate_custom", :force => true do |t|
    t.integer  "user_id",         :limit => 8
    t.integer  "removable_id"
    t.string   "removable_type"
    t.boolean  "remove_children",              :default => false
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  add_index "aggregate_custom", ["removable_id", "removable_type"], :name => "index_aggregate_custom_on_removable_id_and_removable_type"
  add_index "aggregate_custom", ["removable_id"], :name => "index_aggregate_custom_on_removable_id"
  add_index "aggregate_custom", ["removable_type"], :name => "index_aggregate_custom_on_removable_type"
  add_index "aggregate_custom", ["user_id"], :name => "index_aggregate_custom_on_user_id"

  create_table "data_campaign", :force => true do |t|
    t.string  "title",                                                      :limit => 200
    t.integer "advertise_agency_id",                                        :limit => 8
    t.boolean "limit_is_active",                                                                                           :default => false
    t.date    "limit_date_start"
    t.date    "limit_date_stop"
    t.float   "limit_budget_limit",                                                                                        :default => 0.0
    t.float   "limit_budget_balance",                                                                                      :default => 100.0
    t.integer "limit_play_interruption_per_unique_listener_count_limit",                                                   :default => 0
    t.integer "limit_play_interruption_per_unique_listener_minutes_window",                                                :default => 0
    t.float   "playslot_A_play_interruption_cost_per_play",                                                                :default => 0.0
    t.float   "playslot_A_play_request_cost_per_play",                                                                     :default => 0.0
    t.float   "playslot_A_play_request_cost_per_unique_listener",                                                          :default => 0.0
    t.float   "playslot_B_play_interruption_cost_per_play",                                                                :default => 0.0
    t.float   "playslot_B_play_request_cost_per_play",                                                                     :default => 0.0
    t.float   "playslot_B_play_request_cost_per_unique_listener",                                                          :default => 0.0
    t.float   "playslot_C_play_interruption_cost_per_play",                                                                :default => 0.0
    t.float   "playslot_C_play_request_cost_per_play",                                                                     :default => 0.0
    t.float   "playslot_C_play_request_cost_per_unique_listener",                                                          :default => 0.0
    t.float   "playslot_D_play_interruption_cost_per_play",                                                                :default => 0.0
    t.float   "playslot_D_play_request_cost_per_play",                                                                     :default => 0.0
    t.float   "playslot_D_play_request_cost_per_unique_listener",                                                          :default => 0.0
    t.enum    "playmatrix_sunday_00",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_01",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_02",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_03",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_04",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_05",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_06",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_07",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_08",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_09",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_10",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_11",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_12",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_13",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_14",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_15",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_16",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_17",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_18",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_19",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_20",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_21",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_22",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_sunday_23",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_00",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_01",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_02",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_03",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_04",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_05",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_06",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_07",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_08",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_09",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_10",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_11",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_12",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_13",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_14",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_15",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_16",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_17",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_18",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_19",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_20",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_21",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_22",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_monday_23",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_00",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_01",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_02",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_03",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_04",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_05",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_06",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_07",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_08",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_09",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_10",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_11",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_12",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_13",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_14",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_15",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_16",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_17",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_18",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_19",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_20",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_21",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_22",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_tuesday_23",                                      :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_00",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_01",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_02",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_03",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_04",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_05",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_06",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_07",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_08",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_09",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_10",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_11",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_12",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_13",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_14",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_15",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_16",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_17",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_18",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_19",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_20",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_21",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_22",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_wednesday_23",                                    :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_00",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_01",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_02",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_03",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_04",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_05",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_06",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_07",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_08",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_09",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_10",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_11",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_12",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_13",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_14",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_15",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_16",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_17",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_18",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_19",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_20",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_21",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_22",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_thursday_23",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_00",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_01",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_02",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_03",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_04",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_05",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_06",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_07",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_08",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_09",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_10",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_11",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_12",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_13",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_14",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_15",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_16",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_17",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_18",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_19",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_20",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_21",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_22",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_friday_23",                                       :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_00",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_01",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_02",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_03",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_04",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_05",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_06",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_07",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_08",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_09",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_10",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_11",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_12",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_13",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_14",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_15",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_16",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_17",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_18",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_19",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_20",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_21",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_22",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.enum    "playmatrix_saturday_23",                                     :limit => [:A, :B, :C, :D],                    :default => :A
    t.integer "advertise_interruption_prompt_id",                           :limit => 8
    t.enum    "advertise_request_type",                                     :limit => [:PROMPT, :SIPTRANSFER],             :default => :PROMPT
    t.integer "advertise_request_prompt_id",                                :limit => 8
    t.string  "advertise_request_siptransfer_sip_string"
    t.enum    "advertise_request_siptransfer_callid_mode",                  :limit => [:CLEAN, :LISTENERANI, :LISTENERID], :default => :LISTENERID
    t.integer "advertise_request_siptransfer_preconnect_prompt_id",         :limit => 8
    t.integer "advertise_request_siptransfer_failconnect_prompt_id",        :limit => 8
  end

  add_index "data_campaign", ["advertise_agency_id"], :name => "fk_data_campaign_1"
  add_index "data_campaign", ["limit_budget_limit", "limit_budget_balance"], :name => "dispatcher_3"
  add_index "data_campaign", ["limit_date_start", "limit_date_stop"], :name => "dispatcher_2"
  add_index "data_campaign", ["limit_is_active"], :name => "dispatcher_1"

  create_table "data_campaign_prompt", :force => true do |t|
    t.string    "title",            :limit => 200
    t.integer   "campaign_id",      :limit => 8
    t.integer   "media_kb",                        :default => 0
    t.integer   "media_seconds",                   :default => 0
    t.timestamp "date_last_change"
  end

  add_index "data_campaign_prompt", ["campaign_id"], :name => "fk_data_campaign_prompt_1"

  create_table "data_campaign_prompt_blob", :force => true do |t|
    t.binary    "binary",      :limit => 2147483647
    t.timestamp "last_change"
  end

  create_table "data_campaign_publishmap", :force => true do |t|
    t.integer "campaign_id", :limit => 8
  end

  add_index "data_campaign_publishmap", ["campaign_id"], :name => "fk_data_campaign_publishmap_1"

  create_table "data_campaign_publishmap_expression", :force => true do |t|
    t.integer "publishmap_id", :limit => 8
    t.enum    "field",         :limit => [:ENTRYWAY_ID, :GATEWAY_ID, :CONTENT_ID, :ENTRYWAY_PROVIDER_ID, :"3RDPARTY_ID", :BROADCAST_ID, :COUNTRY_ID, :GENRE_ID, :LANGUAGE_ID, :RCA_ID, :LISTENER_ANI_CARRIER_ID, :CAMPAIGN_PLAYSLOT, :LISTENER_IS_ANONYMOUS]
    t.enum    "operator",      :limit => [:EQUAL, :NOT_EQUAL, :IN_CSV_LIST, :NOT_IN_CSV_LIST, :IS_EMPTY, :IS_NOT_EMPTY, :IS_TRUE, :IS_FALSE]
    t.string  "value",         :limit => 8192
  end

  add_index "data_campaign_publishmap_expression", ["publishmap_id"], :name => "fk_data_campaign_publishmap_querie_1"

  create_table "data_content", :force => true do |t|
    t.string  "title",                                        :limit => 200
    t.integer "broadcast_id",                                 :limit => 8
    t.integer "country_id",                                   :limit => 8
    t.integer "language_id",                                  :limit => 8
    t.integer "genre_id",                                     :limit => 8
    t.string  "media_type",                                   :limit => 32,  :default => "SHOUTCAST"
    t.string  "media_url"
    t.boolean "advertise_trigger_enable_listenerpreroll",                    :default => true
    t.boolean "advertise_trigger_enable_listenertimeout",                    :default => true
    t.boolean "advertise_trigger_enable_conferencetiemout",                  :default => false
    t.boolean "advertise_trigger_enable_conferenceadreplace",                :default => false
    t.boolean "is_deleted",                                                  :default => false
  end

  add_index "data_content", ["broadcast_id"], :name => "fk_data_content_1_idx"
  add_index "data_content", ["country_id"], :name => "fk_data_content_1_idx1"
  add_index "data_content", ["genre_id"], :name => "gener_idx"
  add_index "data_content", ["language_id"], :name => "fk_data_content_1_idx2"

  create_table "data_entryway", :force => true do |t|
    t.string  "title",             :limit => 200
    t.string  "did_e164",          :limit => 32
    t.integer "gateway_id",        :limit => 8
    t.integer "country_id",        :limit => 8
    t.integer "3rdparty_id",       :limit => 8
    t.integer "entryway_provider", :limit => 8
    t.boolean "is_deleted",                       :default => false
    t.boolean "is_default",                       :default => false
  end

  add_index "data_entryway", ["3rdparty_id"], :name => "fk_data_entryway_1_idx2"
  add_index "data_entryway", ["country_id"], :name => "fk_data_entryway_1_idx3"
  add_index "data_entryway", ["did_e164"], :name => "DID"
  add_index "data_entryway", ["entryway_provider"], :name => "fk_data_entryway_1_idx"
  add_index "data_entryway", ["gateway_id"], :name => "fk_data_entryway_1_idx1"
  add_index "data_entryway", ["gateway_id"], :name => "gateway"
  add_index "data_entryway", ["title"], :name => "title"

  create_table "data_entryway_provider", :force => true do |t|
    t.string "title", :limit => 200
  end

  create_table "data_gateway", :force => true do |t|
    t.string  "title",                             :limit => 200
    t.integer "country_id",                        :limit => 8
    t.integer "language_id",                       :limit => 8
    t.integer "broadcast_id",                      :limit => 8
    t.integer "rca_id",                            :limit => 8
    t.boolean "is_deleted",                                                             :default => false
    t.enum    "empty_extension_rule",              :limit => [:ASK_AGAIN, :PLAY_FIRST], :default => :PLAY_FIRST
    t.integer "empty_extension_threshold_count",   :limit => 1,                         :default => 2
    t.enum    "invalid_extension_rule",            :limit => [:ASK_AGAIN, :PLAY_FIRST], :default => :PLAY_FIRST
    t.integer "invalid_extension_threshold_count", :limit => 1,                         :default => 3
    t.boolean "ivr_welcome_enabled",                                                    :default => true
    t.integer "ivr_welcome_prompt_id",             :limit => 8
    t.integer "ivr_extension_ask_prompt_id",       :limit => 8
    t.boolean "ivr_extension_invalid_enabled",                                          :default => true
    t.integer "ivr_extension_invalid_prompt_id",   :limit => 8
  end

  add_index "data_gateway", ["broadcast_id"], :name => "fk_data_gateway_3_idx"
  add_index "data_gateway", ["country_id"], :name => "fk_data_gateway_1_idx"
  add_index "data_gateway", ["ivr_extension_ask_prompt_id"], :name => "fk_data_gateway_6"
  add_index "data_gateway", ["ivr_extension_invalid_prompt_id"], :name => "fk_data_gateway_7"
  add_index "data_gateway", ["ivr_welcome_prompt_id"], :name => "fk_data_gateway_5"
  add_index "data_gateway", ["language_id"], :name => "fk_data_gateway_2_idx"
  add_index "data_gateway", ["rca_id"], :name => "fk_data_gateway_4_idx"

  create_table "data_gateway_conference", :force => true do |t|
    t.integer "gateway_id", :limit => 8
    t.integer "content_id", :limit => 8
    t.string  "extension",  :limit => 16
  end

  add_index "data_gateway_conference", ["content_id"], :name => "fk_data_gateway_content_2_idx"
  add_index "data_gateway_conference", ["gateway_id"], :name => "fk_data_gateway_content_1_idx"

  create_table "data_gateway_prompt", :force => true do |t|
    t.string    "title",            :limit => 200
    t.integer   "gateway_id",       :limit => 8
    t.integer   "media_kb",                        :default => 0
    t.integer   "media_seconds",                   :default => 0
    t.timestamp "date_last_change"
  end

  add_index "data_gateway_prompt", ["gateway_id"], :name => "fk_data_gateway_prompt_1"

  create_table "data_gateway_prompt_blob", :force => true do |t|
    t.binary    "binary",      :limit => 2147483647
    t.timestamp "last_change"
  end

  create_table "data_group_3rdparty", :force => true do |t|
    t.string  "title",      :limit => 200
    t.boolean "is_deleted",                :default => false
  end

  create_table "data_group_advertise_agency", :force => true do |t|
    t.string  "title",      :limit => 200
    t.boolean "is_deleted",                :default => false
  end

  create_table "data_group_broadcast", :force => true do |t|
    t.string  "title",      :limit => 200
    t.boolean "is_deleted",                :default => false
  end

  create_table "data_group_country", :force => true do |t|
    t.string  "title",       :limit => 200
    t.string  "iso_alpha_2", :limit => 2
    t.string  "iso_alpha_3", :limit => 3
    t.string  "iso_numeric", :limit => 3
    t.boolean "is_deleted",                 :default => false
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
    t.string  "title",      :limit => 200
    t.boolean "is_deleted",                :default => false
  end

  create_table "data_listener", :force => true do |t|
    t.string  "title",                      :limit => 200
    t.boolean "flag_push_marketing_opt_in",                :default => false
    t.string  "area_code"
  end

  create_table "data_listener_ani", :force => true do |t|
    t.integer  "listener_id",        :limit => 8
    t.string   "ani_e164",           :limit => 64
    t.integer  "carrier_id",         :limit => 8
    t.datetime "carrier_last_check"
    t.string   "carrier_OCN",        :limit => 32
  end

  add_index "data_listener_ani", ["ani_e164"], :name => "ani"
  add_index "data_listener_ani", ["carrier_id"], :name => "fk_data_listener_ani_2_idx"
  add_index "data_listener_ani", ["carrier_last_check"], :name => "lastcheck"
  add_index "data_listener_ani", ["listener_id"], :name => "fk_data_listener_ani_1_idx"

  create_table "data_listener_ani_carrier", :force => true do |t|
    t.string "title", :limit => 200
    t.string "OCN",   :limit => 32
  end

  add_index "data_listener_ani_carrier", ["OCN"], :name => "index2", :unique => true

  create_table "data_listener_at_campaign", :force => true do |t|
    t.integer   "listener_id",                                           :limit => 8
    t.integer   "context_at_id",                                         :limit => 8
    t.timestamp "statistics_first_session_date"
    t.datetime  "statistics_last_session_date"
    t.datetime  "statistics_interruption_first_session_date"
    t.datetime  "statistics_interruption_last_session_date"
    t.string    "statistics_interruption_last_sessions_timestamp",       :limit => 1024
    t.string    "statistics_interruption_last_sessions_log_campaign_id", :limit => 1024
    t.integer   "statistics_interruption_sessions_count",                :limit => 8
    t.integer   "statistics_interruption_sessions_seconds",              :limit => 8
    t.datetime  "statistics_request_first_session_date"
    t.datetime  "statistics_request_last_session_date"
    t.string    "statistics_request_last_sessions_timestamp",            :limit => 1024
    t.string    "statistics_request_last_sessions_log_campaign_id",      :limit => 1024
    t.integer   "statistics_request_sessions_count",                     :limit => 8
    t.integer   "statistics_request_sessions_seconds",                   :limit => 8
  end

  add_index "data_listener_at_campaign", ["listener_id"], :name => "fk_data_listener_at_campaign_1_idx"
  add_index "data_listener_at_campaign", ["statistics_first_session_date"], :name => "index2"

  create_table "data_listener_at_content", :force => true do |t|
    t.integer   "listener_id",                            :limit => 8
    t.integer   "context_at_id",                          :limit => 8
    t.timestamp "statistics_first_session_date"
    t.datetime  "statistics_last_session_date"
    t.string    "statistics_last_sessions_timestamp",     :limit => 1024
    t.string    "statistics_last_sessions_log_listen_id", :limit => 1024
    t.integer   "statistics_sessions_count",              :limit => 8
    t.integer   "statistics_sessions_seconds",            :limit => 8
  end

  add_index "data_listener_at_content", ["context_at_id"], :name => "fk_data_listener_at_content_2_idx"
  add_index "data_listener_at_content", ["listener_id"], :name => "fk_data_listener_at_content_1_idx"
  add_index "data_listener_at_content", ["statistics_last_session_date"], :name => "index5"

  create_table "data_listener_at_entryway", :force => true do |t|
    t.integer   "listener_id",                            :limit => 8
    t.integer   "context_at_id",                          :limit => 8
    t.timestamp "statistics_first_session_date"
    t.datetime  "statistics_last_session_date"
    t.string    "statistics_last_sessions_timestamp",     :limit => 1024
    t.string    "statistics_last_sessions_log_listen_id", :limit => 1024
    t.integer   "statistics_sessions_count",              :limit => 8
    t.integer   "statistics_sessions_seconds",            :limit => 8
  end

  add_index "data_listener_at_entryway", ["context_at_id"], :name => "fk_data_listener_at_entryway_2_idx"
  add_index "data_listener_at_entryway", ["listener_id"], :name => "fk_data_listener_at_entryway_1_idx"
  add_index "data_listener_at_entryway", ["statistics_last_session_date"], :name => "index4"

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

  add_index "data_listener_at_gateway", ["context_at_id"], :name => "fk_data_listener_at_gateway_2"
  add_index "data_listener_at_gateway", ["listener_id"], :name => "fk_data_listener_at_gateway_1"
  add_index "data_listener_at_gateway", ["statistics_last_session_date"], :name => "index4"

  create_table "log_call", :force => true do |t|
    t.integer  "server_id",             :limit => 8
    t.string   "asterisk_remote_ip",    :limit => 15
    t.datetime "date_start"
    t.datetime "date_stop"
    t.integer  "seconds"
    t.string   "ani_e164",              :limit => 64
    t.string   "did_e164",              :limit => 64
    t.integer  "listener_id",           :limit => 8
    t.integer  "listener_ani_id",       :limit => 8
    t.boolean  "listener_is_anonymous",               :default => false
    t.integer  "entryway_id",           :limit => 8
    t.integer  "gateway_id",            :limit => 8
    t.boolean  "on_summary",                          :default => false
  end

  add_index "log_call", ["date_start"], :name => "date_start"
  add_index "log_call", ["date_stop"], :name => "date_stop"

  create_table "log_campaign", :force => true do |t|
    t.integer  "log_call_id",                      :limit => 8
    t.integer  "log_listen_id",                    :limit => 8
    t.datetime "date_start"
    t.datetime "date_stop"
    t.integer  "campaign_id",                      :limit => 8
    t.enum     "trigger_type",                     :limit => [:LISTENERMANUAL, :LISTENERTIMEOUT, :LISTENERPREROLL, :LISTENERREQUEST, :CONFERENCEMANUAL, :CONFERENCETIMEOUT, :CONFERENCEADREPLACE]
    t.integer  "advertise_prompt_id",              :limit => 8
    t.integer  "listener_id",                      :limit => 8
    t.boolean  "listener_is_anonymous"
    t.integer  "listener_interruption_play_count", :limit => 8,                                                                                                                                    :default => 0
    t.integer  "listener_request_play_count",      :limit => 8
    t.integer  "seconds",                                                                                                                                                                          :default => 0
    t.integer  "seconds_played",                   :limit => 8
    t.float    "cost_per_play",                                                                                                                                                                    :default => 0.0
    t.float    "cost_per_unique_listener"
    t.float    "cost"
    t.boolean  "is_interruption"
    t.boolean  "is_request"
    t.boolean  "is_playprompt"
    t.boolean  "is_siptransfer"
    t.boolean  "is_perlistener"
    t.boolean  "is_perconference"
  end

  add_index "log_campaign", ["date_start"], :name => "date_start"
  add_index "log_campaign", ["date_stop"], :name => "date_stop"

  create_table "log_campaign_siptransfer", :force => true do |t|
    t.integer  "log_call_id",          :limit => 8
    t.integer  "log_listen_id",        :limit => 8
    t.integer  "log_campaign_id",      :limit => 8
    t.datetime "date_start"
    t.datetime "date_stop"
    t.string   "sip_string"
    t.enum     "callid_mode",          :limit => [:CLEAN, :LISTENERANI, :LISTENERID]
    t.string   "callid_sent"
    t.integer  "seconds",                                                             :default => 0
    t.string   "asterisk_dialstatus",  :limit => 32
    t.string   "asterisk_hangupcause", :limit => 16
  end

  add_index "log_campaign_siptransfer", ["date_start"], :name => "date_start"
  add_index "log_campaign_siptransfer", ["date_stop"], :name => "date_stop"

  create_table "log_listen", :force => true do |t|
    t.integer  "server_id",             :limit => 8
    t.integer  "log_call_id",           :limit => 8
    t.datetime "date_start"
    t.datetime "date_stop"
    t.integer  "seconds",                             :default => 0
    t.string   "extension",             :limit => 16
    t.integer  "content_id",            :limit => 8
    t.integer  "gateway_conference_id", :limit => 8
  end

  add_index "log_listen", ["date_start"], :name => "date_start"
  add_index "log_listen", ["date_stop"], :name => "date_stop"
  add_index "log_listen", ["log_call_id"], :name => "call"

  create_table "now_session", :force => true do |t|
    t.integer  "log_call_id",                               :limit => 8
    t.integer  "log_listen_id",                             :limit => 8
    t.integer  "log_campaign_id",                           :limit => 8
    t.integer  "log_campaign_siptransfer_id",               :limit => 8
    t.integer  "call_server_id",                            :limit => 8
    t.datetime "call_date_start"
    t.string   "call_asterisk_sip_ip",                      :limit => 15
    t.string   "call_asterisk_channel",                     :limit => 64
    t.string   "call_asterisk_uniqueid",                    :limit => 64
    t.string   "call_ani_e164",                             :limit => 32
    t.string   "call_did_e164",                             :limit => 32
    t.boolean  "call_listener_play_welcome",                                                                                                                                                                :default => true
    t.integer  "call_listener_ani_id",                      :limit => 8
    t.integer  "call_listener_id",                          :limit => 8
    t.boolean  "call_listener_is_anonymous"
    t.integer  "call_entryway_id",                          :limit => 8
    t.integer  "call_gateway_id",                           :limit => 8
    t.boolean  "listen_active",                                                                                                                                                                             :default => false
    t.datetime "listen_date_start"
    t.string   "listen_extension",                          :limit => 16
    t.integer  "listen_content_id",                         :limit => 8
    t.integer  "listen_gateway_conference_id",              :limit => 8
    t.integer  "listen_server_id",                          :limit => 8
    t.integer  "listen_last_played_campaign_id",            :limit => 8
    t.datetime "listen_last_played_campaign_timestamp"
    t.integer  "listen_last_played_campaign_log_id",        :limit => 8
    t.string   "listen_asterisk_channel",                   :limit => 64
    t.string   "listen_asterisk_uniqueid",                  :limit => 64
    t.enum     "engine_type",                               :limit => [:LISTEN, :TALK, :PRIVATETALK, :ADVERTISE, :ADVERTISESIPTRANSFER, :HANGUP]
    t.datetime "engine_date_start"
    t.integer  "engine_server_id",                          :limit => 8
    t.string   "engine_asterisk_channel",                   :limit => 64
    t.string   "engine_asterisk_uniqueid",                  :limit => 64
    t.enum     "engine_advertise_trigger_type",             :limit => [:LISTENERMANUAL, :LISTENERTIMEOUT, :LISTENERPREROLL, :LISTENERREQUEST, :CONFERENCEMANUAL, :CONFERENCETIMEOUT, :CONFERENCEADREPLACE]
    t.integer  "engine_campaign_id",                        :limit => 8
    t.enum     "next_step_1_engine_type",                   :limit => [:LISTEN, :TALK, :PRIVATETALK, :ADVERTISE, :ADVERTISESIPTRANSFER, :HANGUP]
    t.enum     "next_step_1_engine_advertise_trigger_type", :limit => [:LISTENERMANUAL, :LISTENERTIMEOUT, :LISTENERPREROLL, :LISTENERREQUEST, :CONFERENCEMANUAL, :CONFERENCETIMEOUT, :CONFERENCEADREPLACE]
    t.integer  "next_step_1_engine_campaign_id",            :limit => 8
    t.enum     "next_step_2_engine_type",                   :limit => [:LISTEN, :TALK, :PRIVATETALK, :ADVERTISE, :ADVERTISESIPTRANSFER, :HANGUP]
    t.enum     "next_step_2_engine_advertise_trigger_type", :limit => [:LISTENERMANUAL, :LISTENERTIMEOUT, :LISTENERPREROLL, :LISTENERREQUEST, :CONFERENCEMANUAL, :CONFERENCETIMEOUT, :CONFERENCEADREPLACE]
    t.integer  "next_step_2_engine_campaign_id",            :limit => 8
    t.enum     "last_engine_type",                          :limit => [:LISTEN, :TALK, :PRIVATETALK, :ADVERTISE, :ADVERTISESIPTRANSFER, :HANGUP]
    t.enum     "last_engine_advertise_trigger_type",        :limit => [:LISTENERMANUAL, :LISTENERTIMEOUT, :LISTENERPREROLL, :LISTENERREQUEST, :CONFERENCEMANUAL, :CONFERENCETIMEOUT, :CONFERENCEADREPLACE]
    t.integer  "last_engine_campaign_id",                   :limit => 8
  end

  add_index "now_session", ["engine_type"], :name => "engine_now"

  create_table "summary_listeners_by_campaign", :force => true do |t|
    t.date    "date"
    t.integer "campaign_id",                        :limit => 8
    t.integer "status_not_active"
    t.integer "status_active"
    t.integer "status_lost"
    t.integer "active_by_new"
    t.integer "active_by_return"
    t.integer "frequency_listen_dialy"
    t.integer "frequency_listen_weekly"
    t.integer "frequency_unknown"
    t.integer "frequency_0_to_5_minutes_per_day"
    t.integer "frequency_5_to_20_minutes_per_day"
    t.integer "frequency_20_to_60_minutes_per_day"
    t.integer "frequency_more_60_minutes_per_day"
  end

  add_index "summary_listeners_by_campaign", ["date"], :name => "date"

  create_table "summary_listeners_by_content", :force => true do |t|
    t.date    "date"
    t.integer "content_id",                         :limit => 8
    t.integer "status_not_active"
    t.integer "status_active"
    t.integer "status_lost"
    t.integer "active_by_new"
    t.integer "active_by_return"
    t.integer "frequency_listen_dialy"
    t.integer "frequency_listen_weekly"
    t.integer "frequency_unknown"
    t.integer "frequency_0_to_5_minutes_per_day"
    t.integer "frequency_5_to_20_minutes_per_day"
    t.integer "frequency_20_to_60_minutes_per_day"
    t.integer "frequency_more_60_minutes_per_day"
  end

  add_index "summary_listeners_by_content", ["content_id"], :name => "fk_summary_listeners_by_content_1_idx"
  add_index "summary_listeners_by_content", ["date"], :name => "date"

  create_table "summary_listeners_by_content_broadcast", :force => true do |t|
    t.date    "date"
    t.integer "status_not_active"
    t.integer "status_active"
    t.integer "status_lost"
    t.integer "active_by_new"
    t.integer "active_by_return"
    t.integer "frequency_listen_dialy"
    t.integer "frequency_listen_weekly"
    t.integer "frequency_unknown"
    t.integer "frequency_0_to_5_minutes_per_day"
    t.integer "frequency_5_to_20_minutes_per_day"
    t.integer "frequency_20_to_60_minutes_per_day"
    t.integer "frequency_more_60_minutes_per_day"
    t.integer "broadcast_id",                       :limit => 8
  end

  add_index "summary_listeners_by_content_broadcast", ["broadcast_id"], :name => "fk_summary_listeners_by_content_broadcast_1_idx"
  add_index "summary_listeners_by_content_broadcast", ["date"], :name => "date"

  create_table "summary_listeners_by_content_country", :force => true do |t|
    t.date    "date"
    t.integer "status_not_active"
    t.integer "status_active"
    t.integer "status_lost"
    t.integer "active_by_new"
    t.integer "active_by_return"
    t.integer "frequency_listen_dialy"
    t.integer "frequency_listen_weekly"
    t.integer "frequency_unknown"
    t.integer "frequency_0_to_5_minutes_per_day"
    t.integer "frequency_5_to_20_minutes_per_day"
    t.integer "frequency_20_to_60_minutes_per_day"
    t.integer "frequency_more_60_minutes_per_day"
    t.integer "country_id",                         :limit => 8
  end

  add_index "summary_listeners_by_content_country", ["country_id"], :name => "fk_summary_listeners_by_content_country_1_idx"
  add_index "summary_listeners_by_content_country", ["date"], :name => "date"

  create_table "summary_listeners_by_content_language", :force => true do |t|
    t.date    "date"
    t.integer "status_not_active"
    t.integer "status_active"
    t.integer "status_lost"
    t.integer "active_by_new"
    t.integer "active_by_return"
    t.integer "frequency_listen_dialy"
    t.integer "frequency_listen_weekly"
    t.integer "frequency_unknown"
    t.integer "frequency_0_to_5_minutes_per_day"
    t.integer "frequency_5_to_20_minutes_per_day"
    t.integer "frequency_20_to_60_minutes_per_day"
    t.integer "frequency_more_60_minutes_per_day"
    t.integer "language_id",                        :limit => 8
  end

  add_index "summary_listeners_by_content_language", ["date"], :name => "date"
  add_index "summary_listeners_by_content_language", ["language_id"], :name => "fk_summary_listeners_by_content_language_1_idx"

  create_table "summary_listeners_by_entryway", :force => true do |t|
    t.date    "date"
    t.integer "entryway_id",                        :limit => 8
    t.integer "status_not_active"
    t.integer "status_active"
    t.integer "status_lost"
    t.integer "active_by_new"
    t.integer "active_by_return"
    t.integer "frequency_listen_dialy"
    t.integer "frequency_listen_weekly"
    t.integer "frequency_unknown"
    t.integer "frequency_0_to_5_minutes_per_day"
    t.integer "frequency_5_to_20_minutes_per_day"
    t.integer "frequency_20_to_60_minutes_per_day"
    t.integer "frequency_more_60_minutes_per_day"
  end

  add_index "summary_listeners_by_entryway", ["date"], :name => "date"
  add_index "summary_listeners_by_entryway", ["entryway_id"], :name => "fk_summary_listeners_by_entryway_1_idx"

  create_table "summary_listeners_by_entryway_3rdparty", :force => true do |t|
    t.date    "date"
    t.integer "3rdparty_id",                        :limit => 8
    t.integer "status_not_active"
    t.integer "status_active"
    t.integer "status_lost"
    t.integer "active_by_new"
    t.integer "active_by_return"
    t.integer "frequency_listen_dialy"
    t.integer "frequency_listen_weekly"
    t.integer "frequency_unknown"
    t.integer "frequency_0_to_5_minutes_per_day"
    t.integer "frequency_5_to_20_minutes_per_day"
    t.integer "frequency_20_to_60_minutes_per_day"
    t.integer "frequency_more_60_minutes_per_day"
  end

  add_index "summary_listeners_by_entryway_3rdparty", ["3rdparty_id"], :name => "fk_summary_listeners_by_entryway_3rdparty_1_idx"
  add_index "summary_listeners_by_entryway_3rdparty", ["date"], :name => "date"

  create_table "summary_listeners_by_gateway", :force => true do |t|
    t.date    "date"
    t.integer "gateway_id",                         :limit => 8
    t.integer "status_not_active"
    t.integer "status_active"
    t.integer "status_lost"
    t.integer "active_by_new"
    t.integer "active_by_return"
    t.integer "frequency_listen_dialy"
    t.integer "frequency_listen_weekly"
    t.integer "frequency_unknown"
    t.integer "frequency_0_to_5_minutes_per_day"
    t.integer "frequency_5_to_20_minutes_per_day"
    t.integer "frequency_20_to_60_minutes_per_day"
    t.integer "frequency_more_60_minutes_per_day"
  end

  add_index "summary_listeners_by_gateway", ["date"], :name => "date"
  add_index "summary_listeners_by_gateway", ["gateway_id"], :name => "fk_summary_listeners_by_gateway_1_idx"

  create_table "summary_listeners_by_gateway_broadcast", :force => true do |t|
    t.date    "date"
    t.integer "broadcast_id",                       :limit => 8
    t.integer "status_not_active"
    t.integer "status_active"
    t.integer "status_lost"
    t.integer "active_by_new"
    t.integer "active_by_return"
    t.integer "frequency_listen_dialy"
    t.integer "frequency_listen_weekly"
    t.integer "frequency_unknown"
    t.integer "frequency_0_to_5_minutes_per_day"
    t.integer "frequency_5_to_20_minutes_per_day"
    t.integer "frequency_20_to_60_minutes_per_day"
    t.integer "frequency_more_60_minutes_per_day"
  end

  add_index "summary_listeners_by_gateway_broadcast", ["broadcast_id"], :name => "fk_summary_listeners_by_gateway_broadcast_1_idx"
  add_index "summary_listeners_by_gateway_broadcast", ["date"], :name => "date"

  create_table "summary_listeners_by_gateway_rca", :force => true do |t|
    t.date    "date"
    t.integer "rca_id",                             :limit => 8
    t.integer "status_not_active"
    t.integer "status_active"
    t.integer "status_lost"
    t.integer "active_by_new"
    t.integer "active_by_return"
    t.integer "frequency_listen_dialy"
    t.integer "frequency_listen_weekly"
    t.integer "frequency_unknown"
    t.integer "frequency_0_to_5_minutes_per_day"
    t.integer "frequency_5_to_20_minutes_per_day"
    t.integer "frequency_20_to_60_minutes_per_day"
    t.integer "frequency_more_60_minutes_per_day"
  end

  add_index "summary_listeners_by_gateway_rca", ["date"], :name => "date"
  add_index "summary_listeners_by_gateway_rca", ["rca_id"], :name => "fk_summary_listeners_by_gateway_rca_1_idx"

  create_table "summary_sessions_by_campaign", :force => true do |t|
    t.date    "date"
    t.integer "hour"
    t.integer "campaign_id",       :limit => 8
    t.integer "campaign_media_id", :limit => 8
    t.integer "sessions",          :limit => 8
    t.integer "seconds",           :limit => 3
    t.float   "usage_points"
    t.float   "price_entryway"
    t.float   "price_gateway"
    t.float   "price_content"
    t.float   "price_campaign"
  end

  add_index "summary_sessions_by_campaign", ["date", "hour"], :name => "datehr"
  add_index "summary_sessions_by_campaign", ["date"], :name => "date"

  create_table "summary_sessions_by_content", :force => true do |t|
    t.date    "date"
    t.integer "hour"
    t.integer "content_id",           :limit => 8
    t.integer "country_id",           :limit => 8
    t.integer "language_id",          :limit => 8
    t.integer "genre_id",             :limit => 8
    t.integer "broadcast_id",         :limit => 8
    t.integer "sessions",             :limit => 8
    t.integer "sessions_acd_10sec",   :limit => 3
    t.integer "sessions_acd_1min",    :limit => 3
    t.integer "sessions_acd_5min",    :limit => 3
    t.integer "sessions_acd_20min",   :limit => 3
    t.integer "sessions_acd_1hr",     :limit => 3
    t.integer "sessions_acd_2hr",     :limit => 3
    t.integer "sessions_acd_6hr",     :limit => 3
    t.integer "sessions_acd_more6hr", :limit => 3
    t.integer "seconds",              :limit => 3
  end

  add_index "summary_sessions_by_content", ["broadcast_id"], :name => "fk_summary_minutes_listen_sessions_content_5_idx"
  add_index "summary_sessions_by_content", ["content_id"], :name => "fk_summary_minutes_listen_sessions_content_1_idx"
  add_index "summary_sessions_by_content", ["country_id"], :name => "fk_summary_minutes_listen_sessions_content_2_idx"
  add_index "summary_sessions_by_content", ["date", "hour"], :name => "datehr"
  add_index "summary_sessions_by_content", ["date"], :name => "date"
  add_index "summary_sessions_by_content", ["genre_id"], :name => "fk_summary_minutes_listen_sessions_content_4_idx"
  add_index "summary_sessions_by_content", ["language_id"], :name => "fk_summary_minutes_listen_sessions_content_3_idx"

  create_table "summary_sessions_by_entryway", :force => true do |t|
    t.date    "date"
    t.integer "hour"
    t.integer "entryway_id",          :limit => 8
    t.integer "entryway_provider_id", :limit => 8
    t.integer "country_id",           :limit => 8
    t.integer "3rdparty_id",          :limit => 8
    t.integer "sessions",             :limit => 3
    t.integer "sessions_acd_10sec",   :limit => 3
    t.integer "sessions_acd_1min",    :limit => 3
    t.integer "sessions_acd_5min",    :limit => 3
    t.integer "sessions_acd_20min",   :limit => 3
    t.integer "sessions_acd_1hr",     :limit => 3
    t.integer "sessions_acd_2hr",     :limit => 3
    t.integer "sessions_acd_6hr",     :limit => 3
    t.integer "sessions_acd_more6hr", :limit => 3
    t.integer "seconds",              :limit => 3
  end

  add_index "summary_sessions_by_entryway", ["3rdparty_id"], :name => "fk_summary_sessions_by_entryway_4_idx"
  add_index "summary_sessions_by_entryway", ["country_id"], :name => "fk_summary_sessions_by_entryway_3_idx"
  add_index "summary_sessions_by_entryway", ["date", "hour"], :name => "datehr"
  add_index "summary_sessions_by_entryway", ["date"], :name => "date"
  add_index "summary_sessions_by_entryway", ["entryway_id"], :name => "fk_summary_sessions_by_entryway_1_idx"
  add_index "summary_sessions_by_entryway", ["entryway_provider_id"], :name => "fk_summary_sessions_by_entryway_2_idx"

  create_table "summary_sessions_by_gateway", :force => true do |t|
    t.date    "date"
    t.integer "hour"
    t.integer "gateway_id",           :limit => 8
    t.integer "country_id",           :limit => 8
    t.integer "language_id",          :limit => 8
    t.integer "rca_id",               :limit => 8
    t.integer "broadcast_id",         :limit => 8
    t.integer "sessions",             :limit => 8
    t.integer "sessions_acd_10sec",   :limit => 3
    t.integer "sessions_acd_1min",    :limit => 3
    t.integer "sessions_acd_5min",    :limit => 3
    t.integer "sessions_acd_20min",   :limit => 3
    t.integer "sessions_acd_1hr",     :limit => 3
    t.integer "sessions_acd_2hr",     :limit => 3
    t.integer "sessions_acd_6hr",     :limit => 3
    t.integer "sessions_acd_more6hr", :limit => 3
    t.integer "seconds",              :limit => 3
  end

  add_index "summary_sessions_by_gateway", ["broadcast_id"], :name => "fk_summary_minutes_listen_sessions_gateway_5_idx"
  add_index "summary_sessions_by_gateway", ["country_id"], :name => "fk_summary_minutes_listen_sessions_gateway_2_idx"
  add_index "summary_sessions_by_gateway", ["date", "hour"], :name => "datehr"
  add_index "summary_sessions_by_gateway", ["date"], :name => "date"
  add_index "summary_sessions_by_gateway", ["gateway_id"], :name => "fk_summary_minutes_listen_sessions_gateway_1_idx"
  add_index "summary_sessions_by_gateway", ["language_id"], :name => "fk_summary_minutes_listen_sessions_gateway_3_idx"
  add_index "summary_sessions_by_gateway", ["rca_id"], :name => "fk_summary_minutes_listen_sessions_gateway_4_idx"

  create_table "sys_config", :id => false, :force => true do |t|
    t.string "group", :limit => 64,  :null => false
    t.string "name",  :limit => 128, :null => false
    t.string "value"
  end

  create_table "sys_server", :force => true do |t|
    t.string  "title",                         :limit => 200
    t.string  "short_title",                   :limit => 16
    t.string  "ip",                            :limit => 15
    t.integer "location_id",                   :limit => 8
    t.string  "engine_media_remote_ip",        :limit => 200
    t.boolean "is_deleted",                                   :default => false
    t.boolean "advertise_disable_siptransfer"
  end

  add_index "sys_server", ["location_id"], :name => "fk_sys_server_1_idx"

  create_table "sys_server_location", :force => true do |t|
    t.string "title", :limit => 200
  end

  create_table "sys_user", :force => true do |t|
    t.integer  "permission_id",          :limit => 8
    t.string   "title"
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",                  :default => "", :null => false
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
    t.string   "landline"
    t.string   "cellphone"
    t.boolean  "enabled"
  end

  add_index "sys_user", ["permission_id"], :name => "fk_sys_user_1"
  add_index "sys_user", ["permission_id"], :name => "fk_sys_user_1_idx"

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
  add_index "sys_user_resource_3rdparty", ["user_id"], :name => "fk_sys_user_resource_3rdparty_1"

  create_table "sys_user_resource_advertise_agency", :force => true do |t|
    t.integer "user_id",             :limit => 8
    t.integer "advertise_agency_id", :limit => 8
  end

  add_index "sys_user_resource_advertise_agency", ["advertise_agency_id"], :name => "fk_sys_user_resource_advertise_agency_2_idx"
  add_index "sys_user_resource_advertise_agency", ["user_id"], :name => "fk_sys_user_resource_advertise_agency_1"

  create_table "sys_user_resource_broadcast", :force => true do |t|
    t.integer "user_id",      :limit => 8
    t.integer "broadcast_id", :limit => 8
  end

  add_index "sys_user_resource_broadcast", ["broadcast_id"], :name => "fk_sys_user_resource_broadcast_2_idx"
  add_index "sys_user_resource_broadcast", ["user_id"], :name => "fk_sys_user_resource_broadcast_1"

  create_table "sys_user_resource_rca", :force => true do |t|
    t.integer "user_id", :limit => 8
    t.integer "rca_id",  :limit => 8
  end

  add_index "sys_user_resource_rca", ["rca_id"], :name => "fk_sys_user_resource_rca_1_idx1"
  add_index "sys_user_resource_rca", ["user_id"], :name => "fk_sys_user_resource_rca_1"

end
