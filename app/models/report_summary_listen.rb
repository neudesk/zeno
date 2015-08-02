class ReportSummaryListen < ActiveRecord::Base
  belongs_to :data_gateway

  scope :between, lambda {|start_date, end_date| where("report_date >= ? AND report_date <= ?", start_date, end_date)}
end