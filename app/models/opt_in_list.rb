class OptInList < ActiveRecord::Base
  attr_accessible :ani_e164, :listener_id
  validates :ani_e164, format:{ :with => /^\+?[0-9]{10,11}$/, message: "bad format" , on: :create },length: { maximum: 15 }
end
