class Tag < ActiveRecord::Base
  self.table_name = "tags"
  has_many :user_tags
  has_many :users, through: :user_tags, source: :user

  attr_accessible :title
end