namespace :reports do
  desc "CREATE REPORTS AGREGATE TABLE FROM LOG_CALL TABLE"
  task :reports_aggregate => :environment do
    Delayed::Job.enqueue(ImportReports.new("DAILY"),1,5.seconds.from_now)
  end

  desc "CREATE USERS_BY_TIME TABLE FOR GRPHS PAGE "
  task :users_by_time => :environment do
    Delayed::Job.enqueue(UsersByTime.new(''),1,5.seconds.from_now)
  end
  
  desc "CREATE REPORTS_SUMMARY TABLE FOR TOTAL MINUTES"
  task :summary_listen => :environment do
    Delayed::Job.enqueue(SummaryReports.new('DAILY'),1,5.seconds.from_now)
  end

  desc "CREATE TOTAL LISTENER TABLE FOR GRAPHS PAGE"
  task :total_listeners => :environment do
    Delayed::Job.enqueue(ListenerReports.new('RESET'),1,5.seconds.from_now)
  end
  
  desc "CREATE TOTALS MINUTES TABLE FOR MAIN PAGE"
  task :report_total_minutes_by_hour => :environment do
    Delayed::Job.enqueue(TotalMinutesByHourReports.new('RESET'),1,5.seconds.from_now)
  end
  
  desc "CREATE REPORTS AGREGATE TABLE FROM LOG_CALL AND LOG_LISTEN FOR DID'S  TABLE"
  task :reports_aggregate_by_did => :environment do
    Delayed::Job.enqueue(DivideByDidReports.new("DAILY"),1,5.seconds.from_now)
  end
  
  desc "CREATE PARTITIONING LOG_CALL "
  task :partitioning => :environment do
    Delayed::Job.enqueue(LogCallPartitioning.new("DAILY"),1,5.seconds.from_now)
  end
  
  desc "REACHOUT TAB LISTENER MINUTES BY GATEWAY ID "
  task :reachout_tab_listener_minutes => :environment do
    Delayed::Job.enqueue(ReachoutTabListenerMinutes.new(''),1,5.seconds.from_now)
  end
  
  desc "SCHEDULE CAMPAIGNS"
  task :schedule_campaigns => :environment do
    Delayed::Job.enqueue(ScheduleCampaigns.new(''),1,5.seconds.from_now)
  end

  desc "AUTO DELETING CAMPAIGNS"
  task :auto_deleting_campaigns => :environment do
    Delayed::Job.enqueue(AutoDeleteCampaign.new(''),1,5.seconds.from_now)
  end
  
  desc "LOG CALL BUFFER"
  task :log_call_buffer => :environment do
    Delayed::Job.enqueue(LogCallBuffer.new('RESET'),0,5.seconds.from_now)
  end
  #   desc "AREA CODES"
  #  task :area_codes => :environment do
  #    Delayed::Job.enqueue(AreaCode.new(''),1,5.seconds.from_now)
  #  end
  
end
