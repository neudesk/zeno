ZenoRadio::Application.routes.draw do
# at the end of you routes.rb
  mount Ckeditor::Engine => '/ckeditor'

  get "api/station"
  get "api/all_stations"
  get "api/country"
  get "api/timestamp"
  get "api/countries"
  get "search/content_search"
  get "data_gateways/index"
  get "prompts/index"

  match 'api/stations/' => 'api#get_all_stations', :via => :get
  match 'api/station/:gateway_id/files' => 'api#get_stations_files', :via => :get
  match 'api/absolute_station/' => 'api#absolute_station_title', via: :get
  match 'api/toolrequests' => 'api#get_all_tool_requests', :via => :get
  match 'api/toolrequests/:tool_id' => 'api#get_tool', :via => :get

  get 'application/slider_content/:page' => "application#slider_content"
  # get 'my_radio/slider_search' => 'my_radio#slider_search'
  # get 'settings/slider_search' => 'settings#slider_search'
  # get 'prompts/slider_search' => 'prompts#slider_search'

  get 'download' => "download#download", as: "download"
  get "/banner1/:id" => "banner#version1", as: "banner1"
  get "/banner2/:id" => "banner#version2", as: "banner2"
  get "/banner3/:id" => "banner#version3", as: "banner3"
  get "/banner4/:id" => "banner#version4", as: "banner4"
  get "/banner5/:id" => "banner#version5", as: "banner5"
  get "/banner6/:id" => "banner#version6", as: "banner6"
  get "/banner7/:id" => "banner#version7", as: "banner7"

  get 'edit_account' => "users#edit_account", as: "edit_account"
  post 'update_account' => "users#update_account", as: "update_account"

  as :user do
    get "/logout" => "devise/sessions#destroy", as: "logout"
    get "/login" => "devise/sessions#new", as: "login"
  end

  devise_for :users, :controllers => {:sessions => 'sessions' }
  
  scope "/admin" do
    resources :users, :only => [:index, :show, :edit, :update, :new] do
      member do
        put :toggle_lock
        get :info
        delete :destroy
        post :switch
      end
      collection do
        post  :index
        post :save
        match :users_account, :via => [:get, :post, :put]
        match :users_account1, :via => [:get, :post, :put]
        get :groups_options
        get :gateways_checklist
        get :group_list
        get :reset_password
        post :submit_reset_password
      end
    end
    resources :accounts, :only => [:create]
  end
  match 'my_account', :to => 'users#my_account', :via => [:get, :put]
  match 'my_account/update_default_provider', :to => 'users#assign_default_signup_did_provider', :via => :get
  get 'conversations', :to => 'users#conversations'
  post 'users/write_message' => 'users#write_message' , :as => "write_message"
  post 'users/reply_to_message' => 'users#reply_to_message' , :as => "reply_to_message"
  get  'users/get_conversations' => 'users#get_conversations'
  get  'users/get_message_list' => 'users#get_message_list'  

  match '/signup', :to => 'users#signup', :via => :get
  match '/signup/create', :to => 'users#create', :via => :post, :as => 'signup_new_user'

  root :to => "home#index"
  match '/station_percentage', :to => 'home#user_percent', :via => :get
  get 'home/process_campaign_diagram', :to => 'home#process_campaign_diagram'
  get 'home/get_stations' => 'home#get_stations'
  match 'webmail/', to: 'home#admin_user_mailer', via: [:get, :post]
  post 'webmail/attachment', to: 'home#upload_attachment'
  get 'maps/render_map' => 'maps#render_map'

  get 'graphs/get_daily_minutes' => 'graphs#get_daily_minutes'
  get 'graphs/get_weekly_minutes' => 'graphs#get_weekly_minutes'
  get 'graphs/get_hourly_minutes' => 'graphs#get_hourly_minutes'

  get 'session/index' => 'session#index'
  get 'session/get_sessions' => 'session#get_sessions'
  
  get "maps/draw" => "maps#draw"
  put "track_customize" => "home#track_customize"
  get 'charts/countries' => 'charts#countries'
  get 'charts/:country_id/stations' => 'charts#stations'
  get 'charts/:gateway_id/channels' => 'charts#channels'
  get 'charts/aggregate' => "charts#aggregate"
  get 'load_data_for_select' => "charts#load_gateways_or_dids_for_select"
  get 'load_custom' => "charts#load_custom"

  get "my_radio/station" => "my_radio#station"
  put "my_radio/station" => "my_radio#update_station"

  post "prompts" => "prompts#save"
  match "prompts/:id/gsm_audio.gsm" => "prompts#gsm_audio", :as => :prompts_gsm_audio, :via => :get
  match "prompts/:id/gsm_audio.mp3" => "prompts#mp3_audio", :as => :prompts_mp3_audio, :via => :get
  match "prompts/:id/wav_audio.wav" => "prompts#wav_audio", :as => :prompts_wav_audio, :via => :get
  match "prompts/:id/edit" => "prompts#edit", :as => :edit_prompt, :via => :get
  match "prompts/:id" => "prompts#update", :as => :prompt, :via => :put
  match "prompts/:id" => "prompts#destroy", :as => :prompt, :via => :delete
  get "prompts/download_prompt" => "prompts#download_prompt", :as => "download_prompt"

  # match "data_gateways/:data_gateway_id/prompts" => "data_gateways#prompts", :as => :data_gateway_prompts, :via => :get
  # match "data_gateways/:data_gateway_id/prompts" => "data_gateways#update_prompts", :as => :data_gateway_prompts, :via => :put

  get 'reachout_tab_settings/index' => 'reachout_tab_settings#index', :as => :reachout_tab_settings 
  get 'reachout_tab_settings/search_phone' => 'reachout_tab_settings#search_phone'
  post 'reachout_tab_settings/upload_dnc_file' => 'reachout_tab_settings#upload_dnc_file'
  post 'reachout_tab_settings/add_setting' => 'reachout_tab_settings#add_setting'
  post 'reachout_tab_settings/add_call_time' => 'reachout_tab_settings#add_call_time'
  post 'reachout_tab_settings/add_default_prompt' => 'reachout_tab_settings#add_default_prompt'
  post 'reachout_tab_settings/add_phone_dnc' => 'reachout_tab_settings#add_phone_dnc'
  put 'reachout_tab_settings/update_setting/:id' => 'reachout_tab_settings#update_setting', :as => :reachout_tab_settings_update 
  post 'reachout_tab_settings/update_default_did' => 'reachout_tab_settings#update_default_did'
  put 'reachout_tab_settings/activate_broadcaster' => 'reachout_tab_settings#activate_broadcaster'
  put 'reachout_tab_settings/activate_rca' => 'reachout_tab_settings#activate_rca'
  delete 'reachout_tab_settings/delete_phone_dnc/:id' => 'reachout_tab_settings#delete_phone_dnc'

  get 'mapping_rules/index' => 'mapping_rules#index'
  post 'mapping_rules/save' => 'mapping_rules#save'
  delete 'mapping_rules/delete' => 'mapping_rules#delete'
      
  get 'campaign_results/index' => 'campaign_results#index'
  get 'campaign_results/campaigns' => 'campaign_results#campaigns', as: 'new_campaign_results'
  get 'campaign_results/statistics' => 'campaign_results#statistics', as: 'new_campaign_statistics'
  get 'campaign_results/get_campaigns_by_date' => 'campaign_results#get_campaigns_by_date'
  get 'campaign_results/get_campaign_status' => 'campaign_results#get_campaign_status'
  delete 'campaign_results/destroy_campaign' => 'campaign_results#destroy_campaign'
  get 'campaign_results/get_campaigns_by_main_id' => 'campaign_results#get_campaigns_by_main_id'
  get 'campaign_results/get_dids_by_provider' => 'campaign_results#get_dids_by_provider'
  put 'campaign_results/update_campaign_did' => 'campaign_results#update_campaign_did'
  get 'campaign_results/get_campaigns_statuses' => 'campaign_results#get_campaigns_statuses'
  get 'campaign_results/download_phone_lists/:id' => 'campaign_results#download_phone_lists', :as => :download_phone_lists
  put 'campaign_results/update_campaign_status' => 'campaign_results#update_campaign_status'
  get 'campaign_results/get_realtime_calls' => 'campaign_results#get_realtime_calls'
  get 'campaign_results/get_daily_calls' => 'campaign_results#get_daily_calls'
  get 'campaign_results/get_weekly_users' => 'campaign_results#get_weekly_users'
  get 'campaign_results/daily_list_status' => 'campaign_results#daily_list_status'

  
  post 'reachout_tab/save' => 'reachout_tab#save'
  post 'reachout_tab/upload_listeners' => 'reachout_tab#upload_listeners'
  delete 'reachout_tab/destroy_campaign' => 'reachout_tab#destroy_campaign'
  get 'reachout_tab/get_created_campaign_status' => 'reachout_tab#get_created_campaign_status', :as => :get_created_campaign_status

  delete 'reachout_tab/destroy_uploaded_phones/:id' => 'reachout_tab#destroy_uploaded_phones', :as => :reachout_tab_destroy_uploaded_phones
  post 'reachout_tab/add_phone' => 'reachout_tab#add_phone'
  get 'reachout_tab/search_phone' => 'reachout_tab#search_phone'
  get 'reachout_tab/debug/:gateway_id' => 'reachout_tab#campaign_debug'
  delete 'reachout_tab/destroy_phone' => 'reachout_tab#destroy_phone'

  get 'reachout_tab/test' => 'reachout_tab#test'

  get 'data_gateways/check_channel_number' => 'data_gateways#check_channel_number'

  match "new_settings/dup/:id" => "data_gateways#create_dup", :as => 'create_station_dup', :via => :get
  match "new_settings/station/:station_id" => "new_settings#station", :as => 'settings_station', :via => :get
  match "new_settings/detach/:phone_id" => "new_settings#detach_phone", :as => 'detach_phone', :via => :get
  match "new_settings/data_group" => "new_settings#data_group", :as => 'data_group', :via => [:get, :post]
  match "new_settings/data_group/authorized" => "new_settings#check_access", :as => 'data_group_authorized', :via => [:get, :post]
  match "new_settings/data_group/:id/delete" => "new_settings#data_group_delete", :as => 'data_group_delete', :via => [:get]
  match "new_settings/save_data_group" => "new_settings#save_data_groups", :as => 'save_data_group', :via => [:post]
  match "new_settings/data_tagging" => "new_settings#data_tagging", :as => 'data_tagging', :via => [:get, :post]
  match "new_settings/save_data_tagging" => "new_settings#save_data_tagging", :as => 'save_data_tagging', :via => [:post, :get]
  match "new_settings/delete_data_tagging" => "new_settings#delete_data_tagging", :as => 'delete_data_tagging', :via => [:post, :get]
  match "new_settings/send_request" => "new_settings#send_widget_request", :as => 'send_widget_request', :via => [:post]
  match "new_settings/station/update/data_content" => "new_settings#gateway_data_content", as: 'update_gateway_data_content', via: [:get]


  resources :campaign_results, only: [:edit, :index, :show, :destroy] do
    member do
      get :view
    end
  end

  resources :trackings do
    collection do
      get :did
      get :users
      get :stations
      get :country
    end
  end

  resources :data_carrier_rule do
    collection do
    end
  end

  resources :new_campaign do
    collection do
    end
  end

  match 'data_carrier_rule/update', to: 'data_carrier_rule#update_rule', as: 'update_rule'
  match 'data_carrier_rule/gateway/prompt_handler', to: 'data_carrier_rule#set_default_prompt_handler', via: :get, as: 'update_prompt_handler'

  resources :mass_updates do
    collection do
      get :data_groups
      get :save_data_groups
      get :data_group_objects
      post :save_data_groups

      get :data_tags
      get :data_tag_objects
      get :save_data_tags
      post :save_data_tags
    end
  end

  resources :data_gateway_prompts

  match 'data_gateway_prompt/:gateway_id/prompts/', to: 'data_gateway_prompts#get_gateway_prompts', via: :get
  
  resources :reachout_tab do
    collection do
      get :index
    end
  end

  resources :new_settings do
    collection do
    end
    member do
    end
  end
  resource :data_gateway_notes
  resources :new_settings
  resources :stations
  resources :data_gateway_conferences do
    member do
      get :switch
    end
  end
  resources :pending_users do
    collection do
      get :all
      get :save
      get :auto_signups
      get :signup_settings
      get :echosign, as: 'echosign'
    end
    member do
      post :ignore
      post :duplicate
      post :approved
    end
  end

  match 'get_phone_list/' => 'new_settings#list_phone_numbers', :via => :get

  get 'pending_users/all_delete/:id' => 'pending_users#all_delete'
  get 'pending_users/delete_processed_pending_use/:id' => 'pending_users#destroy_processed_pending_user', :as => 'destroy_processed_pending_user'

  match 'pending_users/note/update/' => 'pending_users#update_note', :as => 'update_note', :via => [:post]

  resources :opt_in, :only => "index"  do
    collection do
      get :index
    end
  end

  resources :opt_in_settings, :only => "index"  do
    collection do
      get :index
      get :search_phone
      put :activate_rca
      put :activate_brd
      post :add_phone_opt_in
      post :upload_opt_in_file
      delete '/delete_phone_opt_in/:id' => 'opt_in_settings#delete_phone_opt_in'
      delete :destroy_uploaded_phones
    end
  end

  resources :opt_in_statistics, :only => "index" do
    collection do
      get :index
    end
  end

  resources :data_numerical_reports do
    collection do
      get :rca_minutes
      get :country_minutes
      get :daily_clec_minutes
      get :weekly_clec_minutes
      get :monthly_clec_minutes
    end
  end
  resources :users_and_tags, :only => "index" do
    collection do
      get :tagging
      get :data_group
      get :group_content
      get :tagging_content
      get :group_child_data
      get :group_detail
      put :assign_data
      put :assign_tagging
      get :tagging_child_data
    end
  end

  resources :graphs do
    collection do
      get :chart_a
      get :change_chart_c
      get :change_chart_d
      get :change_total_chart
      get :user_chart
      get :minutes_chart
    end
  end
  resources :reports do
    collection do
      get :get_graphs
      get :render_graphs
    end
  end

  resources :new_report do
    collection do
      get :rca_minutes_minutes, as: 'new_rca_minutes'
      get :country_minutes_minutes, as: 'new_country_minutes'
      get :country_users, as: 'new_country_users'
      get :graph, as: 'new_graph'
      get :get_users_by_time
      get :get_minutes_report
    end
  end

  match 'reports/did/index' => 'reports#did_reports', :as => 'did_report', :via => [:get]
  match 'reports/did/search' => 'reports#did_search_reports', :as => 'did_search_report', :via => [:get]

  resources :extensions, :only => ["index", "destroy"] do
    collection do
      get :search_stream
      get :get_contents
      get :content

      match 'gateway_content/:gateway_content_id/edit' => 'extensions#edit_gateway_content', :as => :edit_gateway_content, :via => :get
      match 'gateway_content/:gateway_content_id/update' => 'extensions#update_gateway_content', :as => :update_gateway_content, :via => :put

      match 'gateway_contents/new' => 'extensions#add_existing_gateway_content', :as => :add_existing_gateway_content, :via => :get
      match 'gateway_contents/create' => 'extensions#save_existing_gateway_content', :as => :save_existing_gateway_content, :via => :post
    end
  end

  resources :data_gateways, :only => ["update", "new", "create", "edit", 'destroy'] do
    collection do
      post :request_content
      post :update_gateway_prop
    end
    member do
      put :update_station
      put :update_prompt
      post :manage_phones
      post :add_phone
      post :create_extension
      post :request_widget_did
    end
    get :assign_dids, controller: :settings
    put :update_station_dids, controller: :settings
    put :unassign_station_dids, controller: :settings
    get :dids_scroll, controller: :settings
  end

  put '/update', :to => 'setting#update_email'

  resources :system_variables, :only => ["index", "update"] do
    collection do
      put :update_email
      post :save
    end
  end


  resources :settings, :only => ["index", "update"] do
  end
  
  resources :data_contents do
    collection do
      post :suggestion
      post :set_content_brd_id
      post :update_schedule
    end
    member do
      get :switch
    end
  end

  match '/api/check_media_url' => 'api#check_media_url', :via => :get
  match '/new_settings/station/data_gateways/check_channel_number' => 'data_gateways#check_channel_number', :via => :get
  match  '/api/data_content_save' => 'api#data_content_save', :via => :post
  match '/api/select_media_url' => 'api#select_media_url', :via => :get

  match '/station/delete/logo/:station_id' => 'data_gateways#delete_logo', :via => :get, :as => 'data_delete_gateway_logo'
  match '*a', :to => 'errors#routing', via: :get
end
