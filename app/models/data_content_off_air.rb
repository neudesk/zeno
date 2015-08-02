class DataContentOffAir < ActiveRecord::Base
   attr_accessible :content_id, :day, :time_start, :time_end, :stream_url, :stream
   has_attached_file :stream
   belongs_to :data_content, foreign_key: :content_id
   validates_attachment_content_type :stream, :content_type => ['application/mp3', 'application/x-mp3', 'audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/x-wav', 'audio/wave', 'audio/x-pn-wav']
 end
   