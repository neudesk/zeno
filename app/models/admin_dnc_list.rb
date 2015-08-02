class AdminDncList < ActiveRecord::Base
  attr_accessible :created_at, :listener_id, :phone_number
  #validates :phone_number, :format => { with: /^\+?[0-9]{3}-?([0-9]{7}|[0-9]-[0-9]{2}-[0-9]{2}-[0-9]{2}|[0-9]{3}-[0-9]{2}-[0-9]-[0-9])$/ }, :presence => true 
  validates :phone_number, format:{ :with => /^\+?[0-9]{10,11}$/, message: "bad format" , on: :create },length: { maximum: 15 }
  
  def self.add_dnc_phone(phone_number)
    if !AdminDncList.find_by_phone_number(phone_number).present?
      ani_e164 = DataListenerAni.find_by_ani_e164(phone_number)
      if ani_e164.present?
        AdminDncList.create(:phone_number => phone_number, :listener_id =>ani_e164.listener_id)
        true
      else
        false
      end
    else
      false
    end
  end
end
