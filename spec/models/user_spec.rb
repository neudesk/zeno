require 'spec_helper'

describe User do
  before do
    @user = FactoryGirl.create(:user, contact_email: "admin@test.com")
    @vn = FactoryGirl.create(:data_group_country, id: 'io', title: "VietNam", is_deleted: 0 )
    puts "="*80
    puts @vn.inspect
    @data_gateway = FactoryGirl.create(:data_gateway, gmaps: "abc", title: "GW1", data_group_country: @vn)

    @summarySessionsByGateway = FactoryGirl.create(:summary_sessions_by_gateway, date: "2013-5-22", hour: 1, data_gateway: @data_gateway, data_group_country: @vn, seconds: 100)

  end
  describe "get_aggregate_custom_chart" do
    before do
      @summarySessionsByGateway = @user.get_aggregate_custom_chart

    end
    it "aaaaa" do
      @summarySessionsByGateway.size should == 0
    end

  end
end
