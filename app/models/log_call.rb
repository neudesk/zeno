class LogCall < ActiveRecord::Base
  attr_accessible :server_id, :asterisk_sip_ip, :date_start, :date_stop, :seconds, 
    :ani_e164, :did_e164, :listener_ani_id, :listener_id, 
    :entryway_id, :gateway_id

  belongs_to :data_listener, foreign_key: :listener_id
  belongs_to :data_entryway, foreign_key: :entryway_id
  belongs_to :data_gateway, foreign_key: :gateway_id
  belongs_to :data_listener_ani, foreign_key: :listener_ani_id
  has_many :log_listens, foreign_key: :log_call_id

  def self.users_by_time(user, options = {})
    begin
      gateway_id = options[:gateway_id]
      entryway_id = options[:entryway_id]
      day = options[:day]
      if day=="0" || day =="1"
        time_period = "hour"
      else
        time_period = "date"
      end
        
      where_cl = (day == "")? [] : ["date_start >= '#{day.to_i.send("days").ago.beginning_of_day}'"]
      where_cl = ["date_start >= '#{day.to_i.send("days").ago.beginning_of_day}' AND date_start <= '#{day.to_i.send("days").ago.end_of_day}'"] if day.to_i == 1
      context_at_id = :gateway_id
      if user.is_thirdparty?
        if entryway_id.nil?
          ids = DataEntryway.with_3rdparty(user).map(&:id)
          where_cl << "entryway_id IN (#{ids.join(",")})" if gateway_id.nil? && !ids.blank?
          where_cl << "entryway_id IN (#{DataEntryway.find_all_by_gateway_id(gateway_id).map(&:id).join(",")})" if gateway_id
        else
          where_cl << "entryway_id = #{entryway_id.to_i}" if entryway_id
        end
        context_at_id = :entryway_id
      elsif user.is_rca? || user.is_broadcaster?
        ids = DataGateway.get_for_rca_broadcast(user).map(&:id)
        where_cl << "gateway_id IN (#{ids.join(",")})" if gateway_id.nil? && !ids.blank?
        where_cl << "gateway_id = #{gateway_id.to_i}" if gateway_id
      end
      select_cl = ("count(log_call.gateway_id) as count, " + time_period + "(log_call.date_start) as " + time_period + ", log_call.gateway_id as context_at_id")        
      if user.is_marketer? && !gateway_id.present? 
        relations = self.where(where_cl.join(" AND ")).select(select_cl).group(time_period).order(time_period + ", #{context_at_id.to_s}")
      else
        ids = user.get_options(gateway_id, entryway_id).first
        relations = self.where(where_cl.join(" AND ")).where("#{context_at_id.to_s} IN (?)", ids).group(time_period)
        .select(select_cl).order(time_period + ", #{context_at_id.to_s}")
      end
      if time_period == "hour"
        add_hours_to_chart(relations)
      else 
        add_date_to_chart(relations,day)
      end
    rescue
    end
  end
  
  def self.add_date_to_chart(relations,day)
    results = []
    date = Date.today
    days = (date-day.to_i..date -1).to_a
    days.each do |day|
      value = 0
      relations.each do |r|
        value = r.count  if r.date == day
      end
      results << [day.strftime('%a %e').to_s,value]
    end
    results
  end
  
  def self.add_hours_to_chart(relations)
    results = []
    time = (0..23).to_a
    time.each do |t|
      value = 0
      relations.each do |r|
        value = r.count if r.hour == t
      end
      results << [t.to_s,value]
    end
    results
  end
  
end