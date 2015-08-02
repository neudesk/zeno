namespace :sign_up_configs do
  desc "creates a signup configuration data"
  task :create_configs => :environment do
    ['default_signup_did_provider', 'default_signup_password'].each do |name|
      config = GlobalSetting.where(:name => name)
      unless config.present?
        GlobalSetting.create(:group => 'GLOBAL_SIGNUP_CONFIGS',
                            :name => name,
                            :value =>'default')
        puts "Signup config #{name} has been created!"
      else
        puts "Signup config #{name} is already exists, Please edit its value on pending users settings tab"
      end
    end
  end
end
