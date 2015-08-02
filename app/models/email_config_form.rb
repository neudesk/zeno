class EmailConfigForm
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :email

  validates :email, :length => {:minimum => 1}


  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

end