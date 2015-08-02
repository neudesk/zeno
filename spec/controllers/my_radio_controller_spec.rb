require 'spec_helper'

describe MyRadioController do

  describe "GET 'stations'" do
    it "returns http success" do
      get 'stations'
      response.should be_success
    end
  end

end
