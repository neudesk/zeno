class Report
  def self.generate_report(station, scope = Date.today.beginning_of_month)
    arr = []

    if scope.is_a?(String)
      month, year = scope.split(",")
      start_date = Date.strptime("#{month}/01/#{year}", "%B/%d/%Y")
    else 
      start_date = scope
    end

    (start_date.day..start_date.end_of_month.day).each_with_index do |interval, idx|
      date = (start_date + interval.days) - 1.days
      return arr if date > Date.today

      if date.strftime("%m").to_i >= 1 && date.strftime("%m").to_i <= 6
        table_name = "report_#{date.strftime('%Y')}_1"
      else
        table_name = "report_#{date.strftime('%Y')}_2"
      end

      if station.is_a?(ActiveRecord::Relation)
        sql = "SELECT report_date, new_users, active_users, sessions, total_minutes FROM #{table_name} WHERE report_date = '#{date}' AND gateway_id IN (#{station.collect(&:id).join(',')})"
      else
        sql = "SELECT report_date, new_users, active_users, sessions, total_minutes FROM #{table_name} WHERE report_date = '#{date}' AND gateway_id = #{station.id}"
      end
      result =  ActiveRecord::Base.connection.execute(sql).to_a
      if result.present?
        arr << [date.strftime("%e").to_i, result.collect {|x| x[1]}.sum, result.collect {|x| x[2]}.sum, result.collect {|x| x[3]}.sum, result.collect {|x| x[4]}.sum ]
      else
        arr << [date.strftime("%e").to_i,0,0,0,0]
      end
    end
  return arr
  end

  def self.weekly_minutes(type_id, type)
    return [] unless type_id.present?
    arr = []
    case type
    when "rca"
      obj = DataGroupRca.find_by_id(type_id)
    when "country"
      obj = DataGroupCountry.find_by_id(type_id)
    end
    return [] unless obj.present?
    ids = obj.gateways.collect(&:id)

    4.downto(0).each do |interval|
      date = Time.now.yesterday.to_date - interval.weeks

      if date.strftime("%m").to_i >= 1 && date.strftime("%m").to_i <= 6
        table_name = "report_#{date.strftime('%Y')}_1"
      else
        table_name = "report_#{date.strftime('%Y')}_2"
      end

      sql = "SELECT total_minutes FROM #{table_name} WHERE report_date = '#{date}' AND gateway_id IN (#{ids.join(',')})"
      result =  ActiveRecord::Base.connection.execute(sql).to_a
      if result.present?
        arr << [date.strftime("%b %-d"), result.collect { |x| x[0]}.sum ]
      else
        arr << [date.strftime("%b %-d"), 0]
      end
    end
    return arr
  end

  def self.current_week_minutes(type_id, type)
    return [] unless type_id.present?
    arr = []
    case type
    when "rca"
      obj = DataGroupRca.find_by_id(type_id)
    when "country"
      obj = DataGroupCountry.find_by_id(type_id)
    end
    ids = obj.gateways.collect(&:id)

    7.downto(1).each do |interval|
      date = Time.now.to_date - interval.days

      if date.strftime("%m").to_i >= 1 && date.strftime("%m").to_i <= 6
        table_name = "report_#{date.strftime('%Y')}_1"
      else
        table_name = "report_#{date.strftime('%Y')}_2"
      end

      sql = "SELECT total_minutes FROM #{table_name} WHERE report_date = '#{date}' AND gateway_id IN (#{ids.join(',')})"
      result =  ActiveRecord::Base.connection.execute(sql).to_a
      if result.present?
        arr << [date.strftime("%a"), result.collect { |x| x[0]}.sum ]
      else
        arr << [date.strftime("%a"), 0]
      end
    end
    return arr
  end

  def self.last_week_minutes(type_id, type)
    return [] unless type_id.present?
    arr = []
    case type
    when "rca"
      obj = DataGroupRca.find_by_id(type_id)
    when "country"
      obj = DataGroupCountry.find_by_id(type_id)
    end
    ids = obj.gateways.collect(&:id)

    7.downto(1).each do |interval|
      date = Time.now.to_date - 1.weeks - interval.days

      if date.strftime("%m").to_i >= 1 && date.strftime("%m").to_i <= 6
        table_name = "report_#{date.strftime('%Y')}_1"
      else
        table_name = "report_#{date.strftime('%Y')}_2"
      end

      sql = "SELECT total_minutes FROM #{table_name} WHERE report_date = '#{date}' AND gateway_id IN (#{ids.join(',')})"
      result =  ActiveRecord::Base.connection.execute(sql).to_a
      if result.present?
        arr << [date.strftime("%a"), result.collect { |x| x[0]}.sum ]
      else
        arr << [date.strftime("%a"), 0]
      end
    end
    return arr
  end


end