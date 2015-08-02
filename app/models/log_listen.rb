class LogListen < ActiveRecord::Base
  attr_accessible :server_id, :log_call_id, :date_start, :date_stop, :seconds, 
                  :extension, :content_id, :gateway_conference_id
  belongs_to :log_call
end