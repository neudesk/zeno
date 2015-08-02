require 'spec_helper'

describe "Numerical Reports" do
  describe "GET Average Time -- Average listening time per user" do
    let(:user) { create(:user) }
    let(:entryway) { create :entryway}
    let(:listener) { build :listener}
    let(:gateway) { create(:gateway)}
    let(:lis_enty) {create(:listener_entryway, :listener => listener)}
    before {
      user.add_role Role::ROLES[:marketer]
      entryway
      listener.save(:validate => false)
      gateway
      lis_enty
      sign_in_as_a_valid_user(user)
      get average_time_numerical_reports_path(:page => 1)
    }
    subject { response }
    describe 'Render View' do
      it "Successfully" do
        expect(response).to render_template("numerical_reports/average_time")
      end
    end

    describe "Assigns data" do
      it "Successfully" do
        current_ability = Ability.new(user)
        stations = user.stations(current_ability)
        time_per_users = user.get_listening_time_per_user(current_ability, 1, 10)
        average_countries = user.get_average_time_of_country(current_ability)
        assigns(:stations).should eq(stations)
        assigns(:time_per_users).should eq(time_per_users)
        assigns(:average_countries).should eq(average_countries)
      end
    end
  end


  describe "GET Minutes divided Clec" do 
    let(:user) { create(:user) }
    let(:entryway) { create :entryway}
    let(:listener) { build :listener}
    let(:gateway) { create(:gateway)}
    let(:lis_enty) {create(:listener_entryway, :listener => listener)}
    before {
      user.add_role Role::ROLES[:marketer]
      entryway
      listener.save(:validate => false)
      gateway
      lis_enty
      sign_in_as_a_valid_user(user)
      get minutes_divided_clec_numerical_reports_path(:page => 1)
    }
    subject { response }
    describe 'Render View' do
      it "Successfully" do
        expect(response).to render_template("numerical_reports/minutes_divided_clec")
      end
    end

    describe "Assigns data" do
      it "Successfully" do
        current_ability = Ability.new(user)
        stations = user.stations(current_ability)
        reports = Kaminari.paginate_array(Entryway.get_numerial_report_marketer).page(1).per(10)      
        assigns(:stations).should eq(stations)
        assigns(:reports).to_json.split("=>").last.should eq(reports.to_json.split("=>").last)
      end
    end
  end

  describe "GET Minutes From Outbound Carrier" do 
    let(:user) { create(:user) }
    let(:entryway) { create :entryway}
    let(:listener) { build :listener}
    let(:gateway) { create(:gateway)}
    let(:lis_enty) {create(:listener_entryway, :listener => listener)}
    before {
      user.add_role Role::ROLES[:marketer]
      entryway
      listener.save(:validate => false)
      gateway
      lis_enty
      sign_in_as_a_valid_user(user)
      get minutes_from_outbound_carrier_numerical_reports_path(:page => 1)
    }
    subject { response }
    describe 'Render View' do
      it "Successfully" do
        expect(response).to render_template("numerical_reports/minutes_from_outbound_carrier")
      end
    end

    describe "Assigns data" do
      it "Successfully" do
        current_ability = Ability.new(user)
        stations = user.stations(current_ability)
        reports = Kaminari.paginate_array(Entryway.get_numerial_report_marketer_outbound_carrier).page(1).per(10)      
        assigns(:stations).should eq(stations)
        assigns(:reports).to_json.split("=>").last.should eq(reports.to_json.split("=>").last)
      end
    end
  end  
end 