class AddColumnsReportDateToReportTotalMinutesByHour < ActiveRecord::Migration
  def change
    add_column :report_total_minutes_by_hour, :report_date, :date
  end
end
