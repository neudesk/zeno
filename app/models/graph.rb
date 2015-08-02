class Graph
  def self.generate_for(days, station)
    case days
    when "today"
      start_date = Date.today.beginning_of_day
      self.generate_for_recent(station, start_date)
    when "yesterday"
      start_date = Date.yesterday.beginning_of_day
      self.generate_for_recent(station, start_date)
    when "7days"
      start_date = Date.today - 8.days
      self.generate_for_long(station, start_date, 1, 7)
    when "30days"
      start_date = Date.today - 33.days
      self.generate_for_long(station, start_date, 3, 10)
    when "90days"
      start_date = Date.today - 110.days
      self.generate_for_long(station, start_date, 10, 10)
    end
  end

  def self.generate_minutes(days, station, format = "%b %e")
    case days
    when "7days"
      start_date = Date.today - 8.days
      self.generate_old_minutes(station, start_date, 1, 7, format)
    when "30days"
      start_date = Date.today - 33.days
      self.generate_old_minutes(station, start_date, 3, 10, format)
    when "90days"
      start_date = Date.today - 110.days
      self.generate_old_minutes(station, start_date, 10, 10, format)
    end
  end

  def self.generate_for_recent(station, start_date)
    arr = []
    id = station.is_a?(ActiveRecord::Relation) ? station.collect(&:id) : station.id
    totaluserforday = 0
    (0..23).each do |interval|
      result = ReportUsersByTime.where(report_date: start_date.to_date, report_hours: interval, gateway_id: id)
      usercount = 0
      result.each do |res|
        usercount += res.users_by_time
      end
      arr << [interval, usercount]
    end
    return arr
  end

  def self.generate_for_long(station, start_date, counter, columns)
    arr = []
    (0..columns).each do |interval|
      start_date1 = start_date + ((interval * counter) + 1).days
      end_date = start_date1 + (counter - 1).days

      if start_date1.strftime("%m").to_i >= 1 && start_date1.strftime("%m").to_i <= 6
        table_name = "report_#{start_date1.strftime('%Y')}_1"
      else
        table_name = "report_#{start_date1.strftime('%Y')}_2"
      end

      if station.is_a?(ActiveRecord::Relation)
        sql = "SELECT report_date,users_by_time FROM #{table_name} WHERE report_date >= '#{start_date1}' AND  report_date <= '#{end_date}' AND gateway_id IN (#{station.collect(&:id).join(',')})"
      else
        sql = "SELECT report_date,users_by_time FROM #{table_name} WHERE report_date >= '#{start_date1}' AND  report_date <= '#{end_date}' AND gateway_id = #{station.id}"
      end
      result =  ActiveRecord::Base.connection.execute(sql).to_a
      if result.present?
        arr << [end_date.strftime("%b %e"), result.collect {|x| x.last}.sum ]
      else
        arr << [end_date.strftime("%b %e"), 0]
      end
    end
    return arr
  end

  def self.generate_old_minutes(station, start_date, counter, columns, format)
    arr = []
    (0..columns).each do |interval|
      start_date1 = start_date + ((interval * counter) + 1).days
      end_date = start_date1 + (counter - 1).days
      if station.is_a?(ActiveRecord::Relation)
        data = ReportSummaryListen.between(start_date1, end_date).collect(&:total_minutes).sum
        arr << [end_date.strftime(format), data]
      else
        data = station.report_minutes.between(start_date1, end_date)
        arr << [end_date.strftime(format), data.collect(&:total_minutes).sum]
      end
    end
    return arr
  end
end