class DefaultPrompt < ActiveRecord::Base
  attr_accessible :name, :prompt
  has_attached_file :prompt, :presence => true
 
  validates_attachment_content_type :prompt, :content_type => ["audio/wav"]
end
