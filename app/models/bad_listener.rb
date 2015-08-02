class BadListener < ActiveRecord::Base
  attr_accessible :ani_e164, :clec, :carrier, :gateway_id, :assigned_clec, :assigned_did
end
