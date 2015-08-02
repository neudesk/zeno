class DataEntrywayProvider < ActiveRecord::Base
  attr_accessible :title
  has_many :data_entryways, foreign_key: :entryway_provider
  has_many :summary_sessions_by_entryways, foreign_key: :entryway_provider_id
  has_many :data_carrier_rules

  def self.minutes_divided_clec
    sum_seconds_for_current_day = <<-EOF
      (SELECT sum(dep.seconds) as current_day
      FROM summary_listen as dep
      INNER JOIN data_entryway as de ON de.id = dep.entryway_id
      WHERE (date(dep.date) = '#{DateTime.now.to_date}' and de.entryway_provider = data_entryway_provider.id))
    EOF

    sum_seconds_for_current_week = <<-EOF
      (SELECT sum(dep.seconds) as current_day
      FROM summary_listen as dep
      INNER JOIN data_entryway as de ON de.id = dep.entryway_id
      WHERE (date(dep.date) BETWEEN '#{DateTime.now.beginning_of_week.to_date}' AND '#{DateTime.now.end_of_week.to_date}' and de.entryway_provider = data_entryway_provider.id))
    EOF
    self.select("data_entryway_provider.title as clec, #{sum_seconds_for_current_day} as current_day, #{sum_seconds_for_current_week} as current_week")
  end
end

# == Schema Information
#
# Table name: data_entryway_provider
#
#  id                            :integer          not null, primary key
#  title                         :string(200)
#  flag_enable_advertise         :boolean          default(TRUE)
#  flag_enable_advertise_forward :boolean          default(TRUE)
#

