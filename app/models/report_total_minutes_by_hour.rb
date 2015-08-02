class ReportTotalMinutesByHour < ActiveRecord::Base
  attr_accessible :report_hours, :total_minutes, :gateway_id
  belongs_to :data_gateway

  def self.generate_for(station, date = Date.today)
    arr = []
    (1..24).each do |time|
      report_date = date - time.hours
      report_hour = report_date.strftime("%l")
      result = ReportTotalMinutesByHour.where(report_date: report_date.to_date, report_hours: report_hour, gateway_id: station.id)
      if result.present?
        arr << [report_date.strftime("%l%p"), result.first.total_minutes]
      else
        arr << [report_date.strftime("%l%p"), 0]
      end
    end
    return arr.reverse
  end
end
