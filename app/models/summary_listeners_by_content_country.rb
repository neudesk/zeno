class SummaryListenersByContentCountry < ActiveRecord::Base
  attr_accessible :country_id, :date, :frequency_listen_dialy, :frequency_listen_weekly,
                  :frequency_unknown, :frequency_0_to_5_minutes_per_day,
                  :frequency_5_to_20_minutes_per_day, :frequency_20_to_60_minutes_per_day,
                  :frequency_more_60_minutes_per_day
  belongs_to :data_country, foreign_key: :country_id
end

# == Schema Information
#
# Table name: summary_listeners_by_content_country
#
#  id                                 :integer          not null, primary key
#  date                               :date
#  status_not_active                  :integer
#  status_active                      :integer
#  status_lost                        :integer
#  active_by_new                      :integer
#  active_by_return                   :integer
#  frequency_listen_dialy             :integer
#  frequency_listen_weekly            :integer
#  frequency_unknown                  :integer
#  frequency_0_to_5_minutes_per_day   :integer
#  frequency_5_to_20_minutes_per_day  :integer
#  frequency_20_to_60_minutes_per_day :integer
#  frequency_more_60_minutes_per_day  :integer
#  country_id                         :integer
#
# Indexes
#
#  date                                           (date)
#  fk_summary_listeners_by_content_country_1_idx  (country_id)
#

