class DataGroupCountry < ActiveRecord::Base
  attr_accessible :title, "iso_alpha_2", :iso_alpha_3
  has_many :data_contents, foreign_key: :country_id
  has_many :data_gateways, foreign_key: :country_id
  has_many :gateways, class_name: "DataGateway", foreign_key: :country_id
  has_many :data_entryways, foreign_key: :country_id
  # has_many :summary_sessions_by_gateways, foreign_key: :country_id
  validates "iso_alpha_2", presence: true, uniqueness: true

  # SHARED METHODS
  include ::SharedMethods

  def refresh_gateways(selected_ids)
    self.gateways.update_all(country_id: nil)
    return true unless selected_ids.present?
    selected_ids.each do |selected_id|
      gateway = DataGateway.find_by_id(selected_id)
      gateway.update_attributes(country_id: id)
    end
  end

  def self.country_aggregate_for_average_listening

    sum_total_listener_select_to_7_weeks = []
    sum_total_time_select_to_7_weeks = []
    8.times do |t|
      start_date = t == 0 ? Date.today.beginning_of_week : t.weeks.ago.beginning_of_week
      end_date = t == 0 ? Date.today.beginning_of_week : t.weeks.ago.end_of_week
      sum_total_listener_select_to_7_weeks << <<-EOF
        (SELECT count(listener_id) as total_listener
         FROM data_group_country as sub_c
         LEFT JOIN data_content as sub_ct ON sub_ct.country_id = sub_c.id
         LEFT JOIN summary_listen ON summary_listen.content_id = sub_ct.id
         LEFT JOIN data_listener_at_content as dlc ON dlc.context_at_id = summary_listen.content_id
         WHERE (sub_c.id = data_group_country.id AND date(date) >= '#{start_date}' AND date(date) <= '#{end_date}')
         GROUP BY sub_c.id) as total_listener_#{t}
      EOF

      sum_total_time_select_to_7_weeks << <<-EOF
        (SELECT sum(seconds)/60 as total_time
         FROM summary_listen
         LEFT JOIN data_content as sub_ct ON sub_ct.id = summary_listen.content_id
         WHERE (sub_ct.country_id = data_group_country.id AND date(date) >= '#{start_date}' AND date(date) <= '#{end_date}')
         GROUP BY sub_ct.country_id) as total_time_#{t}
      EOF
    end

    self.joins("LEFT JOIN data_content as ct ON ct.country_id = data_group_country.id
                LEFT JOIN summary_listen ON ct.id = summary_listen.content_id")
        .select("data_group_country.title as country_name, #{sum_total_listener_select_to_7_weeks.join(" , ")}, #{sum_total_time_select_to_7_weeks.join(" , ")}")
        .group("country_name")
  end

  def self.get_aggregate_tracking_country(from_date=Date.today, to_date=Date.today, hour = 1 )
    result = self.joins("
      LEFT JOIN data_gateway ON `data_gateway`.`country_id` = `data_group_country`.`id`
      INNER JOIN data_entryway ON `data_entryway`.`gateway_id` = `data_gateway`.`id`
      INNER JOIN log_call ON `data_entryway`.`id` = `log_call`.`entryway_id` ")
    .select("sum(seconds/60) as total_minutes")

    result.where("hour(date_start) = ? AND date_start BETWEEN ? and ?", hour, from_date, to_date).order("date_start ASC")
  end

  def self.get_selected_tracking_country(country_ids = [],from_date=Date.today, to_date=Date.today, hour = 1 )

    inner_sql = self.joins("
      LEFT JOIN data_entryway ON `data_entryway`.`country_id` = `data_group_country`.`id` 
      INNER JOIN log_call ON `log_call`.`entryway_id` = `data_entryway`.`id`").where("hour(date_start) = ? AND date_start BETWEEN ? and ? ", hour, from_date, to_date).select("sum(seconds / 60) as total_minutes").to_sql

    result = self.select("data_group_country.title as country_name, (#{inner_sql}) as total_minutes")


    result = result.where("data_group_country.id in (?)", country_ids)

    result.order("country_name ASC")

  end

  def self.get_tagged_countries_on_user(user)
    if user.is_marketer?
      self
    else
      if user.stations.present?
        ids = user.stations.select("distinct data_gateway.country_id").map {|g| g.country_id}
        self.where(:id => ids.present? ? ids : [])
      else
        self
      end
    end
  end

end

# == Schema Information
#
# Table name: data_group_country
#
#  id         :integer          not null, primary key
#  title      :string(200)
#  is_deleted :boolean          default(FALSE)
#  iso_alpha_2   :string(255)
#

