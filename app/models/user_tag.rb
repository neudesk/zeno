class UserTag < ActiveRecord::Base
  self.table_name = "user_tags"
  belongs_to :user
  belongs_to :tag

  attr_accessible :tag_id, :user_id
end