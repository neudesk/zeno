require 'spec_helper.rb'

describe 'Chart request' do
  describe 'GET /charts/countries', :type => :request do
    let(:url) { '/charts/countries' }
    let(:country_ids) { assigns(:countries).collect {|c| c.country_id }}

    describe 'page view' do
      subject { response }
      before { get url }
      # its(:status) { should eql(200) }
      it { should render_template(:partial => 'common_default_charts', locals: { series: assigns(:series), data: country_ids, :level_name => 'countries', :level => 1 }) }
    end

    describe 'data' do
      context '@series' do
      end

      context '@countries' do
        let(:listener_entryways) {
          ListenerEntryway.joins(:gateway => :country)
            .group("gateways.country_id, countries.name")
            .select("gateways.country_id, countries.name as country_name, 'Country' as type_name")
            .order("country_name").limit(2)
        }
        let(:listener_entryways_attrs) { listener_entryways.collect {|g| g.attributes } }
        let(:countries_attrs) { assigns(:countries).collect {|g| g.attributes } }

        before do
          3.times do |i|
            language = create(:language, name:"Language #{i}")
            country = create(:country, name:"Country #{i}")
            gw = build_gateway_with_constrained_data("Gateway", language, country)
            gw.save
          end
          get url
        end

        # its('attributes') { expect(countries_attrs).to match_array(listener_entryways_attrs) }
      end

      context '@opt_selected' do
        let(:day_id) { 1 }
        subject { assigns(:opt_selected) }
        before { get url, day_id:day_id }
        it { should eql(day_id.to_i)}
      end
    end
  end

  describe 'GET /charts/:country_id/stations' do
  end

  describe 'GET /charts/:gateway_id/channels' do
  end

  describe 'GET /charts/aggregate' do
  end

  describe 'GET /load_data_for_select' do
  end

  describe 'GET /load_custom' do
  end
end