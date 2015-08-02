class DataListenerAtContent < ActiveRecord::Base
  alias_attribute :content_id, :context_at_id
  attr_accessible :title, :content_id, :context_at_id, :statistics_first_session_date, :listener_id
  belongs_to :data_listener, foreign_key: :listener_id
  belongs_to :data_content, foreign_key: :context_at_id
  validates :listener_id, :uniqueness => { :scope => [:context_at_id]}
end

# == Schema Information
#
# Table name: data_listener_at_content
#
#  id                         :integer          not null, primary key
#  listener_id                :integer
#  context_at_id                 :integer
#  statistics_first_session_date              :datetime
#  status                     :string(10)
#  status_last_change_date    :datetime
#  is_return                  :boolean          default(FALSE)
#  is_frequency_listen_dialy  :boolean          default(FALSE)
#  is_frequency_listen_weekly :boolean          default(FALSE)
#  average_minutes_per_day    :integer
#  last_session_date          :datetime
#
# Indexes
#
#  fk_data_listener_at_content_1_idx  (listener_id)
#  fk_data_listener_at_content_2_idx  (context_at_id)
#  index2                             (statistics_first_session_date)
#  index3                             (status)
#  index4                             (status_last_change_date)
#  index5                             (last_session_date)
#  index8                             (is_frequency_listen_dialy,is_frequency_listen_weekly)
#

